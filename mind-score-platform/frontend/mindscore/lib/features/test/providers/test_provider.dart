// Assessment test state management.
//
// Manages the full lifecycle of a single assessment attempt:
//   - Loading questions from the API
//   - Countdown timer (auto-submits when time expires)
//   - Recording the user's selected answer per question
//   - Navigating between questions
//   - Submitting answers and receiving the scored result
//
// The Riverpod StateNotifier pattern keeps all mutable state in [TestState]
// and exposes intent-based methods on [TestNotifier].

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

// ─── QuestionModel ────────────────────────────────────────────────────────────

/// Represents a single question as presented in the test screen.
///
/// Extends the API-returned question data with a client-side [selectedIndex]
/// to track the user's current answer without sending partial state to the
/// server.
///
/// Questions are immutable by design; answers are recorded by creating a new
/// instance via [copyWith] and replacing the entry in [TestState.questions].
class QuestionModel {
  /// Server-assigned unique identifier for this question.
  final String id;

  /// The question text displayed to the user.
  final String text;

  /// Ordered list of answer option labels.
  ///
  /// For all current assessments this is the 5-point Likert scale defined
  /// by [_kLikertOptions].
  final List<String> options;

  /// Zero-based index of the user's selected answer, or `null` if unanswered.
  final int? selectedIndex;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    this.selectedIndex,
  });

  /// Returns a copy with [selectedIndex] replaced.
  QuestionModel copyWith({int? selectedIndex}) => QuestionModel(
        id:            id,
        text:          text,
        options:       options,
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}

// ─── TestState ────────────────────────────────────────────────────────────────

/// Immutable snapshot of the current assessment state.
///
/// Fields transition through the lifecycle:
///   loading → questions loaded → answering → submitting → result available
class TestState {
  /// The ID of the currently loaded assessment.
  final String testId;

  /// Human-readable name of the assessment (e.g. "MindType Assessment").
  final String testName;

  /// All questions for the current assessment with their selected answers.
  final List<QuestionModel> questions;

  /// Zero-based index of the question currently displayed.
  final int currentIndex;

  /// Seconds remaining in the countdown timer.
  ///
  /// Initialised to `questions.length * 60` (one minute per question).
  /// When it reaches zero [TestNotifier] auto-submits the test.
  final int remainingSeconds;

  /// `true` once the user has submitted (prevents double-submission).
  final bool isSubmitted;

  /// `true` while loading questions or awaiting the scoring response.
  final bool isLoading;

  /// Non-null when an error occurred during loading or submission.
  final String? error;

  /// The scored result returned by the API after submission.
  final ResultModel? result;

  /// Raw JSON from the submission response — kept for debugging / logging.
  final Map<String, dynamic>? rawResultJson;

  /// UTC timestamp captured when questions finished loading and the timer started.
  ///
  /// Used to calculate [durationSeconds] after submission.
  final DateTime? startedAt;

  /// Elapsed seconds between [startedAt] and the submission timestamp.
  ///
  /// Displayed on the results screen as a "time taken" badge.
  final int? durationSeconds;

  const TestState({
    this.testId = '',
    this.testName = '',
    this.questions = const [],
    this.currentIndex = 0,
    this.remainingSeconds = 600,
    this.isSubmitted = false,
    this.isLoading = false,
    this.error,
    this.result,
    this.rawResultJson,
    this.startedAt,
    this.durationSeconds,
  });

  /// The fraction of questions answered (0.0–1.0), used to drive the
  /// progress bar in the test screen.
  ///
  /// Uses `currentIndex + 1` so the bar fills as the user moves forward,
  /// providing immediate visual feedback.
  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  /// The number of questions that have a selected answer.
  int get answeredCount =>
      questions.where((q) => q.selectedIndex != null).length;

  /// A map of question index to selected option index for all questions.
  Map<int, int?> get selectedAnswers => {
        for (var i = 0; i < questions.length; i++) i: questions[i].selectedIndex,
      };

  /// Returns a copy of this state with the given fields replaced.
  TestState copyWith({
    String? testId,
    String? testName,
    List<QuestionModel>? questions,
    int? currentIndex,
    int? remainingSeconds,
    bool? isSubmitted,
    bool? isLoading,
    String? error,
    ResultModel? result,
    Map<String, dynamic>? rawResultJson,
    DateTime? startedAt,
    int? durationSeconds,
  }) {
    return TestState(
      testId:          testId          ?? this.testId,
      testName:        testName        ?? this.testName,
      questions:       questions       ?? this.questions,
      currentIndex:    currentIndex    ?? this.currentIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitted:     isSubmitted     ?? this.isSubmitted,
      isLoading:       isLoading       ?? this.isLoading,
      error:           error,
      result:          result          ?? this.result,
      rawResultJson:   rawResultJson   ?? this.rawResultJson,
      startedAt:       startedAt       ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

/// The standard 5-point Likert scale options used for all current assessments.
///
/// Defined here (not in the DB) because the option labels are identical across
/// all MPI and MindScore questions, and storing them server-side would add
/// unnecessary storage and network overhead.
const _kLikertOptions = [
  '1 — Strongly Disagree',
  '2 — Disagree',
  '3 — Neutral',
  '4 — Agree',
  '5 — Strongly Agree',
];

// ─── TestNotifier ─────────────────────────────────────────────────────────────

/// Manages the full lifecycle of an active assessment attempt.
///
/// Responsibilities:
///   - [loadTest]: Fetch questions, initialise the countdown timer.
///   - [selectAnswer]: Record the user's choice for a given question.
///   - [nextQuestion] / [prevQuestion] / [goToQuestion]: Navigate questions.
///   - [submitTest]: POST answers, receive scored result, stop the timer.
///   - [reset]: Return to the initial empty state (called on quit or re-take).
///
/// The timer ([_timer]) is a [Timer.periodic] that decrements
/// [TestState.remainingSeconds] every second and triggers [submitTest]
/// automatically when time runs out.
class TestNotifier extends StateNotifier<TestState> {
  Timer? _timer;

  TestNotifier() : super(const TestState());

  /// Loads questions for the given [testId] and starts the countdown timer.
  ///
  /// The timer allots one minute per question.  If no questions are returned
  /// (e.g. because the user's age band has no assigned questions), an
  /// informative error is set instead of showing an empty screen.
  Future<void> loadTest(String testId, {String testName = ''}) async {
    _timer?.cancel();
    state = const TestState(isLoading: true);
    try {
      final raw = await ApiClient.getList(
        '${ApiConstants.questions}?testId=$testId',
      );
      final apiQuestions = raw
          .cast<Map<String, dynamic>>()
          .map(ApiQuestionModel.fromJson)
          .toList();

      final questions = apiQuestions
          .map((q) => QuestionModel(
                id:      q.id,
                text:    q.text,
                options: _kLikertOptions,
              ))
          .toList();

      if (questions.isEmpty) {
        state = const TestState(
          error: 'No questions available for your profile. '
              'Please ensure your date of birth is set correctly.',
        );
        return;
      }

      final seconds = questions.length * 60;
      state = TestState(
        testId:           testId,
        testName:         testName,
        questions:        questions,
        remainingSeconds: seconds,
        startedAt:        DateTime.now(),
      );
      _startTimer();
    } on ApiException catch (e) {
      state = TestState(error: e.message);
    } catch (_) {
      state = const TestState(error: 'Failed to load questions.');
    }
  }

  /// Starts (or restarts) the countdown timer.
  ///
  /// Each tick decrements [TestState.remainingSeconds].  When the counter
  /// reaches zero and questions are loaded, the test is auto-submitted to
  /// ensure the user's answers are not lost.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0 && state.questions.isNotEmpty) {
        submitTest();
      } else if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  /// Records the user's answer for question at [questionIndex].
  ///
  /// [optionIndex] is the zero-based index into [QuestionModel.options].
  /// Creates a new list so state remains immutable.
  void selectAnswer(int questionIndex, int optionIndex) {
    final updated = List<QuestionModel>.from(state.questions);
    updated[questionIndex] =
        updated[questionIndex].copyWith(selectedIndex: optionIndex);
    state = state.copyWith(questions: updated);
  }

  /// Advances to the next question if not already on the last one.
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Returns to the previous question if not already on the first one.
  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Jumps directly to the question at [index].
  void goToQuestion(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// Submits all answered questions to the scoring endpoint.
  ///
  /// Only answered questions are included in the payload — unanswered
  /// questions are silently skipped (the server handles partial submissions
  /// gracefully).
  ///
  /// The elapsed duration is captured from [TestState.startedAt] and stored
  /// in [TestState.durationSeconds] for display on the results screen.
  ///
  /// Returns the [ResultModel] on success, or `null` if an error occurred.
  Future<ResultModel?> submitTest() async {
    _timer?.cancel();
    if (state.isSubmitted) return state.result;

    state = state.copyWith(isLoading: true, isSubmitted: true);
    try {
      final answers = state.questions
          .where((q) => q.selectedIndex != null)
          .map((q) => {
                'questionId': q.id,
                // Answer values are 1-indexed on the server (Likert 1–5).
                'value': '${q.selectedIndex! + 1}',
              })
          .toList();

      final json = await ApiClient.post(
        '${ApiConstants.responses}/submit',
        {'testId': state.testId, 'answers': answers},
        auth: true,
      );
      final result = ResultModel.fromJson(json);
      final elapsed = state.startedAt != null
          ? DateTime.now().difference(state.startedAt!).inSeconds
          : null;
      state = state.copyWith(
        isLoading:      false,
        result:         result,
        rawResultJson:  json,
        durationSeconds: elapsed,
      );
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Submission failed.');
      return null;
    }
  }

  /// Cancels the timer and resets all state to the initial empty values.
  ///
  /// Called when the user quits mid-test or navigates away from the results
  /// screen.  Ensures the timer is always cancelled before disposal.
  void reset() {
    _timer?.cancel();
    state = const TestState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Global Riverpod provider for the active assessment session.
///
/// Scoped globally so both the test screen and the results screen can access
/// the same [TestState] (e.g. to read [TestState.result] and
/// [TestState.durationSeconds] on the results screen).
final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (_) => TestNotifier(),
);
