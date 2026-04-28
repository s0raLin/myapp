import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. M3 标志性大标题栏
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('关于'),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // 2. Logo 区域优化：更微妙的投影和比例
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.music_note_rounded, // 建议使用应用 Logo
                          size: 64,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'MikuMusic',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version $_version ($_buildNumber)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. 描述卡片：使用 Filled 卡片风格
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.filled(
                    color: colorScheme.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            '基于 Flutter 的跨平台音乐播放器',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('🎵 | ✨ | 🌐 | ⚡'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. 功能特性与技术栈：使用 Outlined 卡片更符合 M3 规范
                _buildSectionCard(
                  context,
                  title: '功能特性',
                  items: [
                    '🎨 Material 3 动态颜色主题',
                    '🔊 高性能音频引擎',
                    '📂 本地音乐管理',
                    '🎼 歌词同步显示',
                  ],
                ),
                const SizedBox(height: 16),

                // 5. 链接信息：使用统一的 Surface Container 和 ListTile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.outlined(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Icons.code_rounded,
                          label: '项目仓库',
                          value: 'github.com/s0raLin/miku_music',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildInfoTile(
                          context,
                          icon: Icons.history_rounded,
                          label: '更新日志',
                          value: '查看 CHANGELOG.md',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildInfoTile(
                          context,
                          icon: Icons.description_rounded,
                          label: '开源协议',
                          value: 'MIT License',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                Text(
                  'Made with ❤️ by 蒼璃',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 统一的板块卡片构建
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(item, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 使用 ListTile 实现项目信息，自带点击效果和标准布局
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      onTap: () {}, // 可以在这里添加链接跳转
    );
  }
}
