import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

class ResultsState {
  final List<ResultModel> results;
  final bool isLoading;
  final String? error;

  const ResultsState({this.results = const [], this.isLoading = false, this.error});

  ResultsState copyWith({List<ResultModel>? results, bool? isLoading, String? error}) =>
      ResultsState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ResultsNotifier extends StateNotifier<ResultsState> {
  ResultsNotifier() : super(const ResultsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await ApiClient.getList(ApiConstants.results);
      final results = raw
          .cast<Map<String, dynamic>>()
          .map(ResultModel.fromJson)
          .toList();
      state = state.copyWith(results: results, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load results.');
    }
  }
}

final resultsProvider = StateNotifierProvider<ResultsNotifier, ResultsState>(
  (_) => ResultsNotifier(),
);
