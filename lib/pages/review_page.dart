import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chinese_herb_framery/services/review_service.dart';
import 'package:chinese_herb_framery/widgets/review_card.dart';
import '../models/herb.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // 复习池 UI 层不再维护本地状态，全部交由 ReviewService 管理

  // 卡片滑动回调，直接调用 ReviewService
  void _onSwiped(ReviewService reviewService, int herbId, bool mastered) {
    reviewService.markHerbReviewed(herbId, mastered);
    // 未掌握卡片会自动继续出现在复习池，无需本地管理
  }

  @override
  Widget build(BuildContext context) {
    final reviewService = Provider.of<ReviewService>(context);
    // 你需要在主入口 Provider 里注册 ReviewService
    // 正确获取全量中药数据（herbsMap），需在 main.dart Provider 注册
    final herbsMap = Provider.of<Map<int, Herb>>(context);
    final toReview = reviewService.getTodayReviewList(herbsMap);
    final total = reviewService.todayReviewIds.length;
    final reviewed = reviewService.reviewedToday.length;

    final cardWidth = MediaQuery.of(context).size.width * 0.92;
    final cardHeight = 340.0;
    return Scaffold(
      appBar: AppBar(title: const Text('复习')),
      body: total == 0
          // 图片资源完成后，取消下方注释即可显示图片
          // ? Center(
          //     child: Image.asset(
          //       'assets/done.png',
          //       width: 180,
          //       fit: BoxFit.contain,
          //     ),
          //   )
          ? const Center(child: Text('今日无复习任务'))
          : Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight + 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < toReview.length; i++)
                      Positioned(
                        top: 10.0 + i * 6,
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: Dismissible(
                            key: ValueKey(toReview[i].id),
                            direction: DismissDirection.horizontal,
                            onDismissed: (dir) {
                              _onSwiped(
                                reviewService,
                                toReview[i].id,
                                dir == DismissDirection.startToEnd
                                    ? false
                                    : true,
                              );
                            },
                            child: ReviewCard(
                              herb: toReview[i],
                              onMastered: () {
                                _onSwiped(reviewService, toReview[i].id, true);
                              },
                              onWeak: () {
                                _onSwiped(reviewService, toReview[i].id, false);
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildProgressBar(context, reviewed, total),
    );
  }

  Widget _buildProgressBar(BuildContext context, int reviewed, int total) {
    final width = MediaQuery.of(context).size.width * 0.6;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : reviewed / total,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
