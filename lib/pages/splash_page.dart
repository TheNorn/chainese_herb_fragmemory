import 'package:flutter/material.dart';
import 'home_page.dart'; // 替换为你的主页面路径

/// 启动页，显示 GIF 动画，动画结束后自动跳转到主页面
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 2秒后跳转到主页面，可根据GIF时长调整
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // 暂时隐藏开机动画内容
      /*
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 取屏幕宽高较小值的 60% 作为 GIF 尺寸，保证自适应且居中
          final size =
              (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight) *
              1;
          return Center(
            child: Image.asset(
              'assets/splash.gif',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
      */
    );
  }
}
