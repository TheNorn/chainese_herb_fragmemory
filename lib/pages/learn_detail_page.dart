import 'package:flutter/material.dart';
import '../models/herb.dart';

class LearnDetailPage extends StatelessWidget {
  final Herb herb;
  final bool know;
  final ValueChanged<bool> onResult;

  const LearnDetailPage({
    super.key,
    required this.herb,
    required this.know,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('中药详情')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              herb.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('功效: ${herb.effect}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('性味归经: ${herb.taste}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Padding(
              // 留出与卡片边缘的空隙
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ), // 可根据需要调整
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56, // 按钮更大
                      child: ElevatedButton(
                        onPressed: () {
                          onResult(true); // 记住了
                        },
                        child: const Text(
                          '记住了',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // 按钮间距
                  Expanded(
                    child: SizedBox(
                      height: 56, // 按钮更大
                      child: ElevatedButton(
                        onPressed: () {
                          onResult(false); // 记错了
                        },
                        child: const Text(
                          '记错了',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ...后略...
          ],
        ),
      ),
    );
  }
}
