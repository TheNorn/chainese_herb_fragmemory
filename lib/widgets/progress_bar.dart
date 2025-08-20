import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int mastered;
  final int total;

  const ProgressBar({required this.mastered, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : mastered / total;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LinearProgressIndicator(
        value: percent,
        minHeight: 12,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }
}
