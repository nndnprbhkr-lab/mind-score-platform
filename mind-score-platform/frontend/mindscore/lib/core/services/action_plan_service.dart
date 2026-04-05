import 'package:flutter/material.dart';
import '../models/mpi_models.dart';

class ActionPlanStep {
  final String icon;
  final String title;
  final String body;
  final String traitLabel;
  final Color accentColor;

  const ActionPlanStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.traitLabel,
    required this.accentColor,
  });
}

class ActionPlanService {
  ActionPlanService._();

  static List<ActionPlanStep> generate(MpiResult result) {
    final steps = <ActionPlanStep>[];

    // EnergySource
    final energyDim = result.dimensions['EnergySource'];
    if (energyDim != null) {
      final isE = energyDim.dominantPole == 'E';
      steps.add(ActionPlanStep(
        icon: '⚡',
        title: isE
            ? 'Book a team brainstorm this week'
            : 'Block 90 min of deep focus daily',
        body: isE
            ? 'Your expressive energy peaks in group settings — schedule one collaborative session to drive a stuck problem forward.'
            : 'Your reflective style means uninterrupted time is your highest-leverage resource — protect it before others fill it.',
        traitLabel:
            'EnergySource · ${energyDim.dominantPole} · ${energyDim.strength}',
        accentColor: const Color(0xFFFF6B9D),
      ));
    }

    // PerceptionMode
    final perceptionDim = result.dimensions['PerceptionMode'];
    if (perceptionDim != null) {
      final isO = perceptionDim.dominantPole == 'O';
      steps.add(ActionPlanStep(
        icon: '👁',
        title: isO
            ? 'Run a quick user or data check'
            : 'Map out a 6-month possibility space',
        body: isO
            ? 'Before your next decision, pull one concrete data point — your observable instinct is strongest when grounded in evidence.'
            : 'Give your intuitive mind room to explore: spend 30 minutes sketching futures without constraints or criticism.',
        traitLabel:
            'PerceptionMode · ${perceptionDim.dominantPole} · ${perceptionDim.strength}',
        accentColor: const Color(0xFF5DCAA5),
      ));
    }

    // DecisionStyle
    final decisionDim = result.dimensions['DecisionStyle'];
    if (decisionDim != null) {
      final isL = decisionDim.dominantPole == 'L';
      steps.add(ActionPlanStep(
        icon: '⚖️',
        title: isL
            ? 'Present your next idea with data first'
            : 'Name the human impact in your next pitch',
        body: isL
            ? 'Frame your next proposal around numbers and outcomes — your logical lens lands best when the evidence leads the room.'
            : 'Lead with who benefits and how — your values-led style is most persuasive when people, not process, take centre stage.',
        traitLabel:
            'DecisionStyle · ${decisionDim.dominantPole} · ${decisionDim.strength}',
        accentColor: const Color(0xFFF5B740),
      ));
    }

    // LifeApproach
    final lifeDim = result.dimensions['LifeApproach'];
    if (lifeDim != null) {
      final isS = lifeDim.dominantPole == 'S';
      steps.add(ActionPlanStep(
        icon: '🗂',
        title: isS
            ? 'Build a 2-week sprint plan today'
            : 'Say yes to one unplanned opportunity',
        body: isS
            ? 'Your structured preference thrives with a clear runway — break your biggest current goal into daily steps this afternoon.'
            : 'Your adaptive strength is momentum — deliberately leave one slot this week uncommitted and follow what energises you.',
        traitLabel:
            'LifeApproach · ${lifeDim.dominantPole} · ${lifeDim.strength}',
        accentColor: const Color(0xFF6B35C8),
      ));
    }

    // Sort by abs(percentage - 50) descending
    steps.sort((a, b) {
      final aKey = a.traitLabel.split(' · ')[0];
      final bKey = b.traitLabel.split(' · ')[0];
      final aDev = ((result.dimensions[aKey]?.percentage ?? 50) - 50).abs();
      final bDev = ((result.dimensions[bKey]?.percentage ?? 50) - 50).abs();
      return bDev.compareTo(aDev);
    });

    return steps;
  }
}
