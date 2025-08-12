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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, // 保证左对齐
          children: [
            // 标题：中药名，居中显示
            Center(
              child: Text(
                herb.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32), // 空两行
            // 功效，内容加粗且左对齐
            Text.rich(
              TextSpan(
                text: '功效: ',
                style: const TextStyle(fontSize: 18),
                children: [
                  TextSpan(
                    text: herb.effect,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            // 性味归经，内容加粗且左对齐
            Text.rich(
              TextSpan(
                text: '性味归经: ',
                style: const TextStyle(fontSize: 18),
                children: [
                  TextSpan(
                    text: herb.taste,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
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
