import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // 统一跳转方法
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('无法打开链接 $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 监听版本数据
    final version = context.select<MusicProvider, String>((p) => p.appVersion);
    final buildNumber = context.select<MusicProvider, String>(
      (p) => p.buildNumber,
    );

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // M3 风格大标题栏
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('关于'),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Logo 部分使用更具现代感的容器
                  const SizedBox(height: 20),
                  _buildAnimatedHero(colorScheme, theme, version, buildNumber),

                  const SizedBox(height: 32),

                  // 描述卡片：使用更轻量化的设计
                  _buildDescriptionCard(colorScheme, theme),

                  const SizedBox(height: 24),

                  // 功能特性：分组显示
                  _buildSectionTitle(context, '应用特性'),
                  _buildFeatureGrid(colorScheme, theme),

                  const SizedBox(height: 24),

                  // 链接列表：合并为一个圆角列表组
                  _buildSectionTitle(context, '更多信息'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 0.8,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildLinkTile(
                          context,
                          icon: Icons.code_rounded,
                          title: '源代码仓库',
                          subtitle: 'GitHub / s0raLin / miku_music',
                          url: 'https://github.com/s0raLin/miku_music',
                        ),
                        _buildDivider(colorScheme),
                        _buildLinkTile(
                          context,
                          icon: Icons.history_rounded,
                          title: '版本动态',
                          subtitle: '查看更新日志 (Changelog)',
                          url: 'https://github.com/s0raLin/miku_music/releases',
                        ),
                        _buildDivider(colorScheme),
                        _buildLinkTile(
                          context,
                          icon: Icons.policy_outlined,
                          title: '开源协议',
                          subtitle: 'MIT License',
                          url: 'https://opensource.org/licenses/MIT',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 页脚签名
                  Opacity(
                    opacity: 0.6,
                    child: Column(
                      children: [
                        Text(
                          'Made with ❤️ by 蒼璃',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建 Hero 动画区域
  Widget _buildAnimatedHero(
    ColorScheme cs,
    ThemeData theme,
    String v,
    String b,
  ) {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'MikuMusic',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'v$v ($b)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(ColorScheme cs, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text(
        '一个跨平台播放器。基于 Flutter 构建，使用 Material 3 设计语言。',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(ColorScheme cs, ThemeData theme) {
    final features = [
      {'icon': Icons.palette_outlined, 'label': '动态主题'},
      {'icon': Icons.bolt_outlined, 'label': '快速响应'},
      {'icon': Icons.library_music_outlined, 'label': '本地管理'},
      {'icon': Icons.lyrics_outlined, 'label': '同步歌词'},
    ];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: features.map((f) {
        return ListTile(
          // decoration: BoxDecoration(
          //   color: cs.surfaceContainer,
          //   borderRadius: BorderRadius.circular(16),
          // ),
          leading: Icon(f['icon'] as IconData, size: 18, color: cs.primary),
          title: Text(f['label'] as String, style: theme.textTheme.labelLarge),
        );
      }).toList(),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.open_in_new_rounded, size: 16),
      onTap: () => _launchUrl(url),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 20,
      color: cs.outlineVariant.withValues(alpha: 0.3),
    );
  }
}
