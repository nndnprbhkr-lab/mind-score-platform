import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/mpi_models.dart';
import '../../core/services/action_plan_service.dart';

class MpiActionPlanCard extends StatelessWidget {
  final MpiResult result;

  const MpiActionPlanCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final steps = ActionPlanService.generate(result);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1850),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3D2070)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 16, color: Color(0xFFA67CF0)),
              const SizedBox(width: 8),
              Text(
                'Action plan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your profile · 4 personalised steps',
            style: GoogleFonts.poppins(
              color: const Color(0xFF9A85C8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFF3D2070)),
          const SizedBox(height: 12),
          // Steps
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left accent bar
                    Container(
                      width: 3,
                      height: 52,
                      decoration: BoxDecoration(
                        color: step.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(step.icon,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.body,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9A85C8),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    .animate(delay: (index * 80).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.04),
                if (index < steps.length - 1) const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}
