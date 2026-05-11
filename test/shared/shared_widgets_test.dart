import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/components/Shared/index.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

class _SharedDemoPage extends StatelessWidget {
  const _SharedDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared 测试演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AppSectionHeader(
              title: 'AppSectionHeader',
              subtitle: '用于测试中的集中演示',
              action: Text('Action'),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: MediaGridCard(
                title: '夜航星',
                subtitle: '默认文案布局',
                fallbackIcon: Icons.music_note_rounded,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: MediaGridCard(
                title: '午后黑胶',
                subtitle: 'Overlay 文案布局',
                fallbackIcon: Icons.library_music_rounded,
                textLayout: MediaGridCardTextLayout.overlay,
              ),
            ),
            SizedBox(height: 16),
            SongListCardTile(
              title: '青空',
              subtitle: '高亮列表示例',
              fallbackIcon: Icons.queue_music_rounded,
              highlighted: true,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: QuickActionCard(
                title: '扫描音乐',
                subtitle: '快捷操作示例',
                icon: Icons.library_add_check_rounded,
              ),
            ),
            SizedBox(height: 16),
            AppEmptyState(
              icon: Icons.library_music_outlined,
              title: '没有可展示的内容',
              subtitle: '普通布局空状态示例',
              compact: true,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: CustomScrollView(
                physics: NeverScrollableScrollPhysics(),
                slivers: [
                  AppEmptySliver(
                    icon: Icons.album_outlined,
                    title: 'AppEmptySliver',
                    subtitle: 'Sliver 布局空状态示例',
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _demoApp() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: const _SharedDemoPage(),
  );
}

void main() {
  group('Shared widgets', () {
    testWidgets('AppSectionHeader renders title subtitle and action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppSectionHeader(
            title: '最近播放',
            subtitle: '这里是副标题',
            action: Text('更多'),
          ),
        ),
      );

      expect(find.text('最近播放'), findsOneWidget);
      expect(find.text('这里是副标题'), findsOneWidget);
      expect(find.text('更多'), findsOneWidget);
    });

    testWidgets('ArtworkCover shows fallback icon when bytes are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ArtworkCover(fallbackIcon: Icons.album_rounded, size: 120)),
      );

      expect(find.byIcon(Icons.album_rounded), findsOneWidget);
    });

    testWidgets('MediaGridCard overlay layout renders text on card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 220,
            height: 260,
            child: MediaGridCard(
              title: '午夜电台',
              subtitle: 'Overlay demo',
              fallbackIcon: Icons.music_note_rounded,
              textLayout: MediaGridCardTextLayout.overlay,
            ),
          ),
        ),
      );

      expect(find.text('午夜电台'), findsOneWidget);
      expect(find.text('Overlay demo'), findsOneWidget);
    });

    testWidgets('AppEmptySliver works inside CustomScrollView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: const [
                AppEmptySliver(
                  icon: Icons.inbox_outlined,
                  title: '暂无内容',
                  subtitle: '请稍后再试',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('暂无内容'), findsOneWidget);
      expect(find.text('请稍后再试'), findsOneWidget);
    });

    testWidgets('test demo page matches golden', (tester) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_demoApp());
      await tester.pumpAndSettle();

      expect(find.text('Shared 测试演示'), findsOneWidget);

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/shared_demo_page.png'),
      );
    });
  });
}
