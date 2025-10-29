import 'package:flutter/material.dart';

class StepProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        bool isActive = index + 1 <= currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
