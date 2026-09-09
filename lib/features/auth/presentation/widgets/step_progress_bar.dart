import 'package:flutter/material.dart';

/// Segmented progress indicator for the register screen (step 1 of N).
/// Currently static — wire [currentStep] to real onboarding progress once
/// registration becomes a multi-step flow (e.g. profile setup, preferences).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1E5B3D) : const Color(0xFFE4E8E6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
