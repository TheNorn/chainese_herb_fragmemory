import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:go_router/go_router.dart';
import 'package:chinese_herb_framery/pages/home_page.dart';
import 'package:chinese_herb_framery/pages/learn_page.dart';
import 'package:chinese_herb_framery/pages/review_page.dart';
import 'package:chinese_herb_framery/pages/detail_page.dart';
import 'package:chinese_herb_framery/pages/splash_page.dart'; // 导入自定义 GIF 动画开屏页
import 'package:chinese_herb_framery/services/study_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBugly.init(androidAppId: "", iOSAppId: "57d56b24d6");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => StudyService()..init()),
      ],
      child: MyApp(),
    ),
  );
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
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true; // 是否显示开屏动画

  @override
  void initState() {
    super.initState();
    // 延时 2.5 秒后关闭 splash，显示主页面
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      // 显示 GIF 动画开屏页
      return const MaterialApp(
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
      );
    }
    // 显示主应用（带路由）
    return MaterialApp.router(
      title: '中药速记',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
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
