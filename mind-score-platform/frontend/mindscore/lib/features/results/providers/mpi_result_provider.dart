// Derived providers for MPI result data.
//
// These providers project the raw results list into specialised views without
// making additional API calls, following the Riverpod best practice of
// deriving state from a single source of truth ([resultsProvider]).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/mpi_models.dart';
import '../../../features/results/providers/results_provider.dart';

/// Derives the most recent MPI result from [resultsProvider].
///
/// Filters results where [ResultModel.hasMpiData] is `true` (i.e. the result
/// has a 4-letter type code that is not `MIND_SCORE`), picks the first item
/// (the list is already sorted most-recent-first by the server), and
/// constructs a full [MpiResult] from the raw JSON fields.
///
/// Returns:
///   - [AsyncValue.loading()] while [resultsProvider] is loading.
///   - [AsyncValue.error()] if the results fetch failed.
///   - [AsyncValue.data(null)] if the user has no completed MPI assessments.
///   - [AsyncValue.data(MpiResult)] for the most recent MPI result.
///
/// Consumed by [ResultsScreen] and [MpiResultProvider]-dependent widgets to
/// display the user's personality profile without depending on [testProvider]
/// (which may have been reset after navigating away from the test).
final mpiResultProvider = Provider<AsyncValue<MpiResult?>>((ref) {
  final state = ref.watch(resultsProvider);

  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.empty);

  final mpiResult = state.results
      .where((r) => r.hasMpiData)
      .map((r) => MpiResult.fromJson({
            'id':             r.id,
            'testId':         r.testId,
            'testName':       r.testName,
            'score':          r.score,
            'typeCode':       r.typeCode,
            'typeName':       r.typeName,
            'emoji':          r.emoji,
            'tagline':        r.tagline,
            'dimensionScores': r.dimensionScores,
            'insights':       r.insights,
            'createdAtUtc':   r.createdAtUtc.toIso8601String(),
          }))
      .toList();

  // Most-recent result is first (server sorts by descending createdAt).
  return AsyncValue.data(mpiResult.isEmpty ? null : mpiResult.first);
});

/// Tracks which dimension tooltip is currently expanded by its dimension key.
///
/// Only one tooltip can be open at a time — setting a new key closes the
/// previous one.  Setting to `null` collapses all tooltips.
///
/// Used by [MpiDimensionRow] and [MpiDimensionTooltip] to coordinate their
/// open/closed state without local StatefulWidget complexity.
final activeDimensionTooltipProvider = StateProvider<String?>((ref) => null);
