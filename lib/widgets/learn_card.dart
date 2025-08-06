import 'package:flutter/material.dart';
import '../models/herb.dart';

class LearnCard extends StatelessWidget {
  final Herb herb;
  final VoidCallback onKnow;
  final VoidCallback onDontKnow;

  const LearnCard({
    super.key,
    required this.herb,
    required this.onKnow,
    required this.onDontKnow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(32),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              herb.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: onKnow, child: const Text('我知道')),
                ElevatedButton(onPressed: onDontKnow, child: const Text('不知道')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
