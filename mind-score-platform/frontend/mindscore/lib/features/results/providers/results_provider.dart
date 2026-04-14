// Results list state management.
//
// Fetches and caches all scored assessment results for the authenticated user.
// Used by the history screen, the dashboard activity feed, and as a source
// for the derived [mpiResultProvider].

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';

// ─── ResultsState ─────────────────────────────────────────────────────────────

/// Immutable snapshot of the user's historical results list.
class ResultsState {
  /// All scored results returned by `GET /api/results`, most recent first.
  final List<ResultModel> results;

  /// `true` while the API request is in-flight.
  final bool isLoading;

  /// Non-null if the last fetch failed.
  final String? error;

  const ResultsState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  /// Returns a copy with the given fields replaced.
  ResultsState copyWith({
    List<ResultModel>? results,
    bool? isLoading,
    String? error,
  }) =>
      ResultsState(
        results:   results   ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );
}

// ─── ResultsNotifier ─────────────────────────────────────────────────────────

/// Loads the full results list from the server on construction and exposes
/// a [load] method for manual refresh.
///
/// The constructor immediately calls [load] so that any widget watching
/// [resultsProvider] starts with a loading state and receives data as soon
/// as the request completes.
class ResultsNotifier extends StateNotifier<ResultsState> {
  ResultsNotifier() : super(const ResultsState()) {
    load();
  }

  /// Fetches all results for the authenticated user from `GET /api/results`.
  ///
  /// The server returns results in descending chronological order.
  /// On success, replaces [ResultsState.results].  On failure, sets
  /// [ResultsState.error] with a user-facing message.
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

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Global Riverpod provider for the authenticated user's results list.
///
/// Derived providers such as [mpiResultProvider] watch this to compute
/// specialised views (e.g. the most recent MPI result) without making
/// additional network requests.
final resultsProvider = StateNotifierProvider<ResultsNotifier, ResultsState>(
  (_) => ResultsNotifier(),
);
