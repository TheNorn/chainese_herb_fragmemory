import 'package:flutter/material.dart';
import 'package:chinese_herb_framery/models/herb.dart';

class ReviewCard extends StatelessWidget {
  final Herb herb;
  final VoidCallback onMastered;
  final VoidCallback onWeak;

  const ReviewCard({
    super.key,
    required this.herb,
    required this.onMastered,
    required this.onWeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              herb.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              herb.category,
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 30),
            Text(
              herb.effect,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Text(
              '性味: ${herb.taste}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
