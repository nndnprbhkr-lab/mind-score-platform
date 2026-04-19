// Adaptive assessment test state management.
//
// Manages the full lifecycle of a single adaptive assessment attempt:
//   - Fetching one question at a time from the /api/questions/next endpoint
//   - Countdown timer (auto-submits when time expires)
//   - Recording the user's selected answer for the current question
//   - Advancing to the next question (sends answered history to server)
//   - Auto-submitting when the server signals IsComplete = true
//   - Receiving and storing the scored result
//
// The engine is stateless on the server — all session state (answered so far)
// is accumulated client-side in [TestState.answeredSoFar] and POSTed with
// every /api/questions/next call.
//
// The Riverpod StateNotifier pattern keeps all mutable state in [TestState]
// and exposes intent-based methods on [TestNotifier].

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

// ─── AdaptiveAnsweredModel ────────────────────────────────────────────────────

/// A single answered question in the adaptive session history.
///
/// [value] encoding:
///   - Likert questions: 1–5 (1 = Strongly Disagree, 5 = Strongly Agree)
///   - Scenario questions: 0-based option index
class AdaptiveAnsweredModel {
  final String questionId;
  final int value;

  const AdaptiveAnsweredModel({
    required this.questionId,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'value': value,
      };
}

// ─── AdaptiveNextQuestionResponseModel ───────────────────────────────────────

/// Deserialized form of the POST /api/questions/next response.
class AdaptiveNextQuestionResponseModel {
  final ApiQuestionModel? question;
  final bool isComplete;
  final int estimatedRemaining;
  final double progress;
  final int answeredCount;

  const AdaptiveNextQuestionResponseModel({
    required this.question,
    required this.isComplete,
    required this.estimatedRemaining,
    required this.progress,
    required this.answeredCount,
  });

  factory AdaptiveNextQuestionResponseModel.fromJson(Map<String, dynamic> j) {
    final qJson = j['question'] as Map<String, dynamic>?;
    return AdaptiveNextQuestionResponseModel(
      question: qJson != null ? ApiQuestionModel.fromJson(qJson) : null,
      isComplete: j['isComplete'] as bool? ?? false,
      estimatedRemaining: j['estimatedRemaining'] as int? ?? 0,
      progress: (j['progress'] as num?)?.toDouble() ?? 0.0,
      answeredCount: j['answeredCount'] as int? ?? 0,
    );
  }
}

// ─── TestState ────────────────────────────────────────────────────────────────

/// Immutable snapshot of the current adaptive assessment state.
class TestState {
  /// The ID of the currently loaded assessment.
  final String testId;

  /// Human-readable name of the assessment.
  final String testName;

  /// The context the user selected at the start of this assessment.
  final AssessmentContext context;

  /// The question currently being displayed (null while loading or complete).
  final ApiQuestionModel? currentQuestion;

  /// Zero-based index of the user's selected answer for [currentQuestion],
  /// or `null` if the question has not yet been answered.
  final int? selectedIndex;

  /// Ordered history of all questions answered so far — sent to the server
  /// with each /api/questions/next call.
  final List<AdaptiveAnsweredModel> answeredSoFar;

  /// Session progress fraction 0.0–1.0 as reported by the server.
  final double progress;

  /// Estimated number of questions remaining (including the current one).
  final int estimatedRemaining;

  /// Number of questions answered so far (from server response).
  final int answeredCount;

  /// `true` when the server has indicated the session is complete and
  /// [TestNotifier] has triggered auto-submission.
  final bool isComplete;

  /// Seconds remaining in the countdown timer.
  final int remainingSeconds;

  /// `true` once submission has been sent (prevents double-submission).
  final bool isSubmitted;

  /// `true` while fetching the next question or awaiting the scoring response.
  final bool isLoading;

  /// Non-null when an error occurred during loading or submission.
  final String? error;

  /// The scored result returned by the API after submission.
  final ResultModel? result;

  /// Raw JSON from the submission response — kept for debugging.
  final Map<String, dynamic>? rawResultJson;

  /// UTC timestamp captured when the first question loaded and timer started.
  final DateTime? startedAt;

  /// Elapsed seconds between [startedAt] and the submission timestamp.
  final int? durationSeconds;

  const TestState({
    this.testId = '',
    this.testName = '',
    this.context = AssessmentContext.general,
    this.currentQuestion,
    this.selectedIndex,
    this.answeredSoFar = const [],
    this.progress = 0.0,
    this.estimatedRemaining = 0,
    this.answeredCount = 0,
    this.isComplete = false,
    this.remainingSeconds = 1200,
    this.isSubmitted = false,
    this.isLoading = false,
    this.error,
    this.result,
    this.rawResultJson,
    this.startedAt,
    this.durationSeconds,
  });

  /// Returns a copy with the given fields replaced.
  ///
  /// To set [selectedIndex] to a new value pass it directly.
  /// To clear it back to null pass [clearSelectedIndex] = true.
  TestState copyWith({
    String? testId,
    String? testName,
    AssessmentContext? context,
    ApiQuestionModel? currentQuestion,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    List<AdaptiveAnsweredModel>? answeredSoFar,
    double? progress,
    int? estimatedRemaining,
    int? answeredCount,
    bool? isComplete,
    int? remainingSeconds,
    bool? isSubmitted,
    bool? isLoading,
    String? error,
    bool clearError = false,
    ResultModel? result,
    Map<String, dynamic>? rawResultJson,
    DateTime? startedAt,
    int? durationSeconds,
  }) {
    return TestState(
      testId:             testId             ?? this.testId,
      testName:           testName           ?? this.testName,
      context:            context            ?? this.context,
      currentQuestion:    currentQuestion    ?? this.currentQuestion,
      selectedIndex:      clearSelectedIndex
          ? null
          : (selectedIndex ?? this.selectedIndex),
      answeredSoFar:      answeredSoFar      ?? this.answeredSoFar,
      progress:           progress           ?? this.progress,
      estimatedRemaining: estimatedRemaining ?? this.estimatedRemaining,
      answeredCount:      answeredCount      ?? this.answeredCount,
      isComplete:         isComplete         ?? this.isComplete,
      remainingSeconds:   remainingSeconds   ?? this.remainingSeconds,
      isSubmitted:        isSubmitted        ?? this.isSubmitted,
      isLoading:          isLoading          ?? this.isLoading,
      error:              clearError ? null : (error ?? this.error),
      result:             result             ?? this.result,
      rawResultJson:      rawResultJson      ?? this.rawResultJson,
      startedAt:          startedAt          ?? this.startedAt,
      durationSeconds:    durationSeconds    ?? this.durationSeconds,
    );
  }
}

// ─── TestNotifier ─────────────────────────────────────────────────────────────

/// Manages the full lifecycle of an adaptive assessment attempt.
///
/// Responsibilities:
///   - [startAdaptive]: Fetch the first question for a given test + context.
///   - [selectAnswer]: Record the user's answer for the current question.
///   - [nextQuestion]: Append the answer, fetch the next question (or auto-submit).
///   - [submitTest]: POST all collected answers to the scoring endpoint.
///   - [reset]: Return to the initial empty state.
class TestNotifier extends StateNotifier<TestState> {
  Timer? _timer;

  TestNotifier() : super(const TestState());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Begins an adaptive assessment session.
  ///
  /// Fetches the first question from the server and initialises the countdown
  /// timer based on the estimated total question count returned.
  Future<void> startAdaptive(
    String testId,
    AssessmentContext context, {
    String testName = '',
  }) async {
    _timer?.cancel();
    state = TestState(
      testId:   testId,
      testName: testName,
      context:  context,
      isLoading: true,
    );

    try {
      final response = await _fetchNext(testId, context, const []);

      if (response.isComplete || response.question == null) {
        // No questions available for this profile / context.
        state = const TestState(
          error: 'No questions are available for your profile. '
              'Please ensure your date of birth is set correctly.',
        );
        return;
      }

      final initialSeconds = (response.estimatedRemaining + 1) * 60;
      state = TestState(
        testId:             testId,
        testName:           testName,
        context:            context,
        currentQuestion:    response.question,
        progress:           response.progress,
        estimatedRemaining: response.estimatedRemaining,
        answeredCount:      response.answeredCount,
        remainingSeconds:   initialSeconds,
        startedAt:          DateTime.now(),
      );
      _startTimer();
    } on ApiException catch (e) {
      state = TestState(error: e.message);
    } catch (_) {
      state = const TestState(error: 'Failed to load the assessment.');
    }
  }

  /// Records the user's answer for the current question.
  ///
  /// [optionIndex] is the zero-based index of the selected option in
  /// [currentQuestion.options] (Likert) or [scenarioOptions] (Scenario).
  void selectAnswer(int optionIndex) {
    state = state.copyWith(selectedIndex: optionIndex);
  }

  /// Clears the current selection — used by the ephemeral undo action to
  /// cancel an auto-advance before the timer fires.
  void clearSelection() {
    state = state.copyWith(clearSelectedIndex: true);
  }

  /// Appends the current answer to [answeredSoFar], then fetches the next
  /// question.  If the server signals [IsComplete], auto-submits the test.
  Future<void> nextQuestion() async {
    final q = state.currentQuestion;
    if (q == null || state.selectedIndex == null) return;

    // Encode the answer value: Likert → 1-based, Scenario/FollowUp → 0-based.
    final value = q.questionType == QuestionType.scenario
        ? state.selectedIndex!
        : state.selectedIndex! + 1;

    final newAnswered = [
      ...state.answeredSoFar,
      AdaptiveAnsweredModel(questionId: q.id, value: value),
    ];

    state = state.copyWith(
      isLoading:     true,
      answeredSoFar: newAnswered,
      clearSelectedIndex: true,
      clearError:    true,
    );

    try {
      final response = await _fetchNext(state.testId, state.context, newAnswered);

      if (response.isComplete || response.question == null) {
        // Server signals end of session — auto-submit.
        state = state.copyWith(isComplete: true, isLoading: false);
        await submitTest();
        return;
      }

      state = state.copyWith(
        isLoading:          false,
        currentQuestion:    response.question,
        progress:           response.progress,
        estimatedRemaining: response.estimatedRemaining,
        answeredCount:      response.answeredCount,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load next question.');
    }
  }

  /// Submits all collected answers to the scoring endpoint.
  ///
  /// Called automatically when the server signals completion, or manually when
  /// the countdown timer expires.  Guards against double-submission.
  Future<ResultModel?> submitTest() async {
    _timer?.cancel();
    if (state.isSubmitted) return state.result;

    state = state.copyWith(isLoading: true, isSubmitted: true);
    try {
      final answers = state.answeredSoFar
          .map((a) => {'questionId': a.questionId, 'value': '${a.value}'})
          .toList();

      final json = await ApiClient.post(
        '${ApiConstants.responses}/submit',
        {
          'testId': state.testId,
          'answers': answers,
          'context': state.context.apiValue,
        },
        auth: true,
      );
      final result = ResultModel.fromJson(json);
      final elapsed = state.startedAt != null
          ? DateTime.now().difference(state.startedAt!).inSeconds
          : null;
      state = state.copyWith(
        isLoading:       false,
        result:          result,
        rawResultJson:   json,
        durationSeconds: elapsed,
      );
      return result;
    } on ApiException catch (e) {
      // Allow retry — reset isSubmitted so the user can try again.
      state = state.copyWith(
          isLoading: false, isSubmitted: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, isSubmitted: false, error: 'Submission failed.');
      return null;
    }
  }

  /// Cancels the timer and resets all state to the initial empty values.
  void reset() {
    _timer?.cancel();
    state = const TestState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Calls POST /api/questions/next and returns the deserialized response.
  Future<AdaptiveNextQuestionResponseModel> _fetchNext(
    String testId,
    AssessmentContext context,
    List<AdaptiveAnsweredModel> answeredSoFar,
  ) async {
    final json = await ApiClient.post(
      ApiConstants.questionsNext,
      {
        'testId':        testId,
        'context':       context.apiValue,
        'answeredSoFar': answeredSoFar.map((a) => a.toJson()).toList(),
      },
      auth: true,
    );
    return AdaptiveNextQuestionResponseModel.fromJson(json);
  }

  /// Starts (or restarts) the per-second countdown timer.
  ///
  /// When the counter reaches zero the test is auto-submitted using whatever
  /// answers have been collected so far.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0) {
        submitTest();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Global Riverpod provider for the active adaptive assessment session.
final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (_) => TestNotifier(),
);
