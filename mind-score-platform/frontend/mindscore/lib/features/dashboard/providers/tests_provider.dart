import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

class TestsState {
  final List<TestModel> tests;
  final bool isLoading;
  final String? error;

  const TestsState({this.tests = const [], this.isLoading = false, this.error});

  TestsState copyWith({List<TestModel>? tests, bool? isLoading, String? error}) =>
      TestsState(
        tests: tests ?? this.tests,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class TestsNotifier extends StateNotifier<TestsState> {
  TestsNotifier() : super(const TestsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await ApiClient.getList(ApiConstants.tests);
      final tests = list
          .cast<Map<String, dynamic>>()
          .map(TestModel.fromJson)
          .toList();
      state = state.copyWith(tests: tests, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load tests.');
    }
  }
}

final testsProvider = StateNotifierProvider<TestsNotifier, TestsState>(
  (_) => TestsNotifier(),
);
