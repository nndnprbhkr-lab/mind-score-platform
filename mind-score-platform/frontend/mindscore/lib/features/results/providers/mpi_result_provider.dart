import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/mpi_models.dart';
import '../../../features/results/providers/results_provider.dart';

/// Derives the most recent MPI result from the results list.
/// Returns null if the user has no completed MPI tests yet.
final mpiResultProvider = Provider<AsyncValue<MpiResult?>>((ref) {
  final state = ref.watch(resultsProvider);

  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.empty);

  final mpiResult = state.results
      .where((r) => r.hasMpiData)
      .map((r) => MpiResult.fromJson({
            'id': r.id,
            'testId': r.testId,
            'testName': r.testName,
            'score': r.score,
            'typeCode': r.typeCode,
            'typeName': r.typeName,
            'emoji': r.emoji,
            'tagline': r.tagline,
            'dimensionScores': r.dimensionScores,
            'insights': r.insights,
            'createdAtUtc': r.createdAtUtc.toIso8601String(),
          }))
      .toList();

  // Most recent first (results_provider already orders by desc)
  return AsyncValue.data(mpiResult.isEmpty ? null : mpiResult.first);
});

/// Tracks which dimension tooltip is currently open (by dimension key).
/// Only one open at a time. Null = all closed.
final activeDimensionTooltipProvider = StateProvider<String?>((ref) => null);
