import 'package:flutter/material.dart';
import 'package:myapp/contants/Assets/index.dart';
import 'package:myapp/providers/ThemeProvider/index.dart';
import 'package:myapp/router/Extensions/router.dart';
import 'package:myapp/service/Initialization/index.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      // 稍微拉长动画时间（1.2秒），让无背景容器的淡入更优雅、有仪式感
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 标准的 M3 减速曲线，适合淡入
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      // 前 80% 时间完成淡入
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    // 缩放动画：从 85% 放大到 100%，使用平滑的 easeOutCubic
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    final stopwatch = Stopwatch()..start();
    try {
      final settings = await InitializationService.loadInitialSettings();
      if (mounted) {
        context.read<ThemeProvider>().updateFromMap(settings);
      }
    } catch (e) {
      debugPrint("初始化失败: $e");
    }

    // 保持至少 1.8s 的展示时间，避免由于去掉了容器导致视觉上感觉停留时间过短
    final remaining = 1800 - stopwatch.elapsedMilliseconds;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

    if (mounted) context.toHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // 使用 Surface 颜色作为整个页面的底色
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          // 使用 MainAxisAlignment.center 将所有内容居中
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用 Spacer 或 SizedBox 来精细控制 Logo 的垂直位置，这里使用 SizedBox 保持可控
            const Spacer(flex: 2),
            // 1. Logo：彻底去掉 Container
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  MyAssets.mikulogo,
                  // 没有背景容器后，为了不显得单薄，将 Logo 图片尺寸适当放大
                  width: 108,
                  height: 108,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24), // Logo 和标题的间距
            // 2. 品牌名称
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'M3Music',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold, // M3 标题通常加粗
                  color: colorScheme.onSurface,
                  letterSpacing: 1.5, // 增加字间距，更有质感
                ),
              ),
            ),

            const Spacer(), // 将加载指示器推到底部
            // 3. 极简加载指示器
            Padding(
              padding: const EdgeInsets.only(bottom: 64), // 距离底部的安全距离
              child: FadeTransition(
                opacity: _fadeAnimation, // 指示器也一起淡入
                child: SizedBox(
                  width: 32, // 指示器尺寸适中
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3, // 线条粗细
                    strokeCap: StrokeCap.round, // 圆角线条
                    color: colorScheme.primary, // 使用主色
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
