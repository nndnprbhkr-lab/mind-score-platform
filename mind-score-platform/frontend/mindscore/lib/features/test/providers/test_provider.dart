import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

class QuestionModel {
  final String id;
  final String text;
  final List<String> options;
  final int? selectedIndex;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    this.selectedIndex,
  });

  QuestionModel copyWith({int? selectedIndex}) => QuestionModel(
        id: id,
        text: text,
        options: options,
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}

class TestState {
  final String testId;
  final String testName;
  final List<QuestionModel> questions;
  final int currentIndex;
  final int remainingSeconds;
  final bool isSubmitted;
  final bool isLoading;
  final String? error;
  final ResultModel? result;
  final Map<String, dynamic>? rawResultJson;
  final DateTime? startedAt;
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

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  int get answeredCount =>
      questions.where((q) => q.selectedIndex != null).length;

  Map<int, int?> get selectedAnswers => {
        for (var i = 0; i < questions.length; i++) i: questions[i].selectedIndex,
      };

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
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
      rawResultJson: rawResultJson ?? this.rawResultJson,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

const _kLikertOptions = [
  '1 — Strongly Disagree',
  '2 — Disagree',
  '3 — Neutral',
  '4 — Agree',
  '5 — Strongly Agree',
];

class TestNotifier extends StateNotifier<TestState> {
  Timer? _timer;

  TestNotifier() : super(const TestState());

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
                id: q.id,
                text: q.text,
                options: _kLikertOptions,
              ))
          .toList();

      if (questions.isEmpty) {
        state = const TestState(
          error: 'No questions available for your profile. Please ensure your date of birth is set correctly.',
        );
        return;
      }

      final seconds = questions.length * 60;
      state = TestState(
        testId: testId,
        testName: testName,
        questions: questions,
        remainingSeconds: seconds,
        startedAt: DateTime.now(),
      );
      _startTimer();
    } on ApiException catch (e) {
      state = TestState(error: e.message);
    } catch (_) {
      state = const TestState(error: 'Failed to load questions.');
    }
  }

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

  void selectAnswer(int questionIndex, int optionIndex) {
    final updated = List<QuestionModel>.from(state.questions);
    updated[questionIndex] =
        updated[questionIndex].copyWith(selectedIndex: optionIndex);
    state = state.copyWith(questions: updated);
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void goToQuestion(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<ResultModel?> submitTest() async {
    _timer?.cancel();
    if (state.isSubmitted) return state.result;

    state = state.copyWith(isLoading: true, isSubmitted: true);
    try {
      final answers = state.questions
          .where((q) => q.selectedIndex != null)
          .map((q) => {
                'questionId': q.id,
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
        isLoading: false,
        result: result,
        rawResultJson: json,
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

final testProvider = StateNotifierProvider<TestNotifier, TestState>(
  (_) => TestNotifier(),
);
