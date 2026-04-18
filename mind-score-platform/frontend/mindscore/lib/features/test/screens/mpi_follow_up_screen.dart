// MPI Follow-Up Question Screen.
//
// Presents the AI-generated follow-up questions one at a time after the
// initial MPI result has been shown.  Each question has exactly two options;
// the user taps one to advance.  On the last question the answers are
// submitted to POST /api/results/{id}/follow-up and the screen pops,
// triggering a results reload in the caller.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../results/providers/results_provider.dart';

class MpiFollowUpScreen extends ConsumerStatefulWidget {
  final String resultId;
  final List<Map<String, dynamic>> questions;

  const MpiFollowUpScreen({
    super.key,
    required this.resultId,
    required this.questions,
  });

  @override
  ConsumerState<MpiFollowUpScreen> createState() => _MpiFollowUpScreenState();
}

class _MpiFollowUpScreenState extends ConsumerState<MpiFollowUpScreen> {
  int _current = 0;
  final List<Map<String, dynamic>> _answers = [];
  bool _submitting = false;
  String? _error;

  Map<String, dynamic> get _question => widget.questions[_current];
  List<dynamic> get _options => (_question['options'] as List? ?? []);
  bool get _isLast => _current == widget.questions.length - 1;

  Future<void> _selectOption(int optionIndex) async {
    final questionId = _question['id'] as String;
    _answers.add({'questionId': questionId, 'optionIndex': optionIndex});

    if (!_isLast) {
      setState(() => _current++);
      return;
    }

    // Last answer — submit.
    setState(() => _submitting = true);
    try {
      await ApiClient.post(
        '${ApiConstants.results}/${widget.resultId}/follow-up',
        {'answers': _answers},
        auth: true,
      );
      if (mounted) {
        ref.read(resultsProvider.notifier).load();
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _submitting = false;
        _error = 'Failed to submit answers. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Refine Your Profile',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_current + 1) / widget.questions.length,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_current + 1} of ${widget.questions.length}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Question text
                  Text(
                    _question['text'] as String? ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

                  const SizedBox(height: 32),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Options
                  ...List.generate(_options.length, (i) {
                    final option = _options[i] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OptionCard(
                        text: option['text'] as String? ?? '',
                        onTap: () => _selectOption(i),
                        index: i,
                      ).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.05),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final int index;

  const _OptionCard({
    required this.text,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
        ),
      ),
    );
  }
}
