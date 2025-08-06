import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:chinese_herb_app/pages/home_page.dart';
import 'package:chinese_herb_app/pages/learn_page.dart';
import 'package:chinese_herb_app/pages/review_page.dart';
import 'package:chinese_herb_app/pages/detail_page.dart';
import 'package:chinese_herb_app/services/study_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
          create: (_) => StudyService()..init(),
        ), // Initialize StudyService here
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

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '中药速记',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }

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
