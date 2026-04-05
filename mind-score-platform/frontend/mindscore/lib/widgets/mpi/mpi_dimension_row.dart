import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/mpi_models.dart';

class MpiDimensionRow extends StatelessWidget {
  final MpiResult result;

  const MpiDimensionRow({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ordered = result.orderedDimensions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1850),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3D2070)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Dimension breakdown',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...ordered.asMap().entries.map((entry) {
            final index = entry.key;
            final meta = entry.value.key;
            final score = entry.value.value;
            final accentColor = meta.colorForPole(score.dominantPole);
            final poleWord = score.dominantPole == meta.leftPole
                ? meta.leftWord
                : meta.rightWord;

            return Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final trackWidth = constraints.maxWidth - 16 - 8 - 36;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(meta.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    meta.name,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF9A85C8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    poleWord,
                                    style: GoogleFonts.poppins(
                                      color: accentColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Track bar
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D2070),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    width: (score.percentage / 100) *
                                        trackWidth.clamp(0.0, double.infinity),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${score.percentage.round()}%',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (index < ordered.length - 1) const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}
