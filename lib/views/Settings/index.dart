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
            Text("外观", style: Theme.of(context).textTheme.labelLarge),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.dark_mode),
              title: Text("深色模式"),
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (value) => themeProvider.toggleThemeMode(),
              ),
            ),
            Text("主题色", style: Theme.of(context).textTheme.labelLarge),
            ListTile(
              onTap: () {},
              title: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themeColors.map((color) {
                    final isSelected = themeProvider.seedColor == color;
                    return GestureDetector(
                      onTap: () => themeProvider.setSeedColor(color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: colorScheme.primary, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Text("关于", style: Theme.of(context).textTheme.labelLarge),
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
}
