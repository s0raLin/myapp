import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/ThemeProvider/index.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Color> _themeColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text("设置"),
      ),
      backgroundColor: colorScheme.surface,
      body: ListTileTheme(
        data: ListTileThemeData(
          iconColor: colorScheme.primary,
          titleTextStyle: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // _buildSectionHeader('外观'),
            _buildSectionTile(context, "外观"),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.dark_mode),
              title: Text("深色模式"),
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (value) => themeProvider.toggleThemeMode(),
              ),
            ),
            _buildSectionTile(context, "主题色"),
            ListTile(
              onTap: () {},
              title: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themeColors.map((color) {
                    final isSelected = themeProvider.seedColor == color;
                    return _ThemeSeedButton(
                      color: color,
                      isSelected: isSelected,
                      onTap: () => themeProvider.setSeedColor(color),
                    );
                  }).toList(),
                ),
              ),
            ),
            _buildSectionTile(context, "关于"),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.info_outline),
              title: Text("版本"),
              trailing: Text(
                "1.0.0",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //构建分组标题
  Widget _buildSectionTile(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// 优化的主题色选择按钮
class _ThemeSeedButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeSeedButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isSelected ? 12 : 22),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}
