import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:go_router/go_router.dart';
import 'package:chinese_herb_framery/pages/home_page.dart';
import 'package:chinese_herb_framery/pages/learn_page.dart';
import 'package:chinese_herb_framery/pages/review_page.dart';
import 'package:chinese_herb_framery/pages/detail_page.dart';
// import 'package:chinese_herb_framery/pages/splash_page.dart';
import 'package:chinese_herb_framery/services/review_service.dart';
import 'package:chinese_herb_framery/services/study_service.dart';
import 'utils/herb_loader.dart';
import 'models/herb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 加载所有中药数据
  final herbsMap = await loadAllHerbs();
  runApp(MyApp(herbsMap: herbsMap));
}

class AppState extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

/// 应用主入口，负责显示开屏动画和主路由

class MyApp extends StatefulWidget {
  final Map<int, Herb> herbsMap;
  const MyApp({super.key, required this.herbsMap});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider<Map<int, Herb>>.value(value: widget.herbsMap),
        ChangeNotifierProvider(create: (_) => StudyService()),
        ChangeNotifierProvider(create: (_) => ReviewService()..init()),
      ],
      child: MaterialApp.router(
        title: '中药速记',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // 主路由配置，包含首页和详情页
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'detail/:herbId',
            builder: (context, state) {
              final herbId = state.pathParameters['herbId']!;
              return DetailPage(herbId: herbId);
            },
          ),
        ],
      ),
    ],
  );
}

/// 主页面，包含底部导航栏
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pages = [const HomePage(), const LearnPage(), const ReviewPage()];

    return Scaffold(
      body: pages[appState.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: appState.currentIndex,
        onTap: (index) => appState.changeTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '学习'),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: '复习'),
        ],
      ),
    );
  }
}
