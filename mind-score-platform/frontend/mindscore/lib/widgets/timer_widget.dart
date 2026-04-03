import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final bool isUrgent;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    this.isUrgent = false,
  });

  String get _formatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _color {
    if (remainingSeconds <= 60) return AppColors.error;
    if (remainingSeconds <= 180) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final urgent = remainingSeconds <= 60;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withOpacity(urgent ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            urgent ? Icons.warning_amber_rounded : Icons.timer_outlined,
            size: 18,
            color: _color,
          ),
          const SizedBox(width: 6),
          Text(
            _formatted,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}
