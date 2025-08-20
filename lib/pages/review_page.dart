import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chinese_herb_framery/services/study_service.dart';
import 'package:chinese_herb_framery/widgets/review_card.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  Widget _buildBottomBar(BuildContext context, int totalReviews) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // 只左对齐
          children: [
            Text(
              '已复习: $_currentIndex/$totalReviews',
              style: const TextStyle(fontSize: 16),
            ),
            // 已移除“完成”按钮
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context);
    final reviewHerbs = studyService.todayReviews;

    return Scaffold(
      appBar: AppBar(title: const Text('复习')),
      body: reviewHerbs.isEmpty
          ? const Center(child: Text('今日无复习任务'))
          : PageView.builder(
              controller: _pageController,
              itemCount: reviewHerbs.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return ReviewCard(
                  herb: reviewHerbs[index],
                  onMastered: () {
                    studyService.updateRecord(
                      reviewHerbs[index].id,
                      mastered: true,
                    );
                    // 滑动到下一个
                    if (index < reviewHerbs.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  onWeak: () {
                    studyService.updateRecord(
                      reviewHerbs[index].id,
                      mastered: false,
                    );
                    // 滑动到下一个
                    if (index < reviewHerbs.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: _buildBottomBar(
        context,
        reviewHerbs.length,
      ), // 添加了context参数
    );
  }
}
