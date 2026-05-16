import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as ft;

enum MediaGridCardTextLayout { below, overlay }

enum AppToastTone { neutral, success, warning, error }

// ---------------------------------------------------------------------------
// 统一圆角常量
// card      → 卡片/面板外轮廓
// inner     → 卡片内部的子元素（封面图、icon 容器等），比外轮廓略小
// tile      → 列表行卡片，比普通卡片稍小
// ---------------------------------------------------------------------------
abstract final class AppRadius {
  static const double card = 16;
  static const double inner = 10;
  static const double tile = 12;

  static BorderRadius get cardBR => BorderRadius.circular(card);
  static BorderRadius get innerBR => BorderRadius.circular(inner);
  static BorderRadius get tileBR => BorderRadius.circular(tile);
}

// ---------------------------------------------------------------------------
// AppToast
// 在 iOS/desktop 上用 M3 SnackBar 代替自制 Overlay；Android 保留系统 Toast。
// ---------------------------------------------------------------------------
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppToastTone tone = AppToastTone.neutral,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (Platform.isAndroid) {
      final text = title != null ? '$title: $message' : message;
      ft.Fluttertoast.showToast(
        msg: text,
        toastLength: ft.Toast.LENGTH_SHORT,
        gravity: ft.ToastGravity.BOTTOM,
        fontSize: 14.0,
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final colorScheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (tone) {
      AppToastTone.success => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        Icons.check_circle_rounded,
      ),
      AppToastTone.warning => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        Icons.warning_rounded,
      ),
      AppToastTone.error => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.error_rounded,
      ),
      AppToastTone.neutral => (
        colorScheme.inverseSurface,
        colorScheme.onInverseSurface,
        Icons.info_rounded,
      ),
    };

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
  }) => show(
    context,
    message: message,
    title: title,
    tone: AppToastTone.success,
    duration: duration,
  );

  static void neutral(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 1500),
  }) => show(
    context,
    message: message,
    title: title,
    tone: AppToastTone.neutral,
    duration: duration,
  );

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2000),
  }) => show(
    context,
    message: message,
    title: title,
    tone: AppToastTone.warning,
    duration: duration,
  );

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2500),
  }) => show(
    context,
    message: message,
    title: title,
    tone: AppToastTone.error,
    duration: duration,
  );
}

// ---------------------------------------------------------------------------
// AppSectionHeader
// ---------------------------------------------------------------------------
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppPanel
// Card.filled 负责裁切圆角（clipBehavior: antiAlias），InkWell 的涟漪
// 自动被裁切到卡片边界，无需再给 InkWell 单独传 borderRadius。
// ---------------------------------------------------------------------------
class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  // 默认统一使用 AppRadius.cardBR
  final BorderRadius? borderRadius;

  const AppPanel({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      color: color ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppRadius.cardBR,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ArtworkCover
// ---------------------------------------------------------------------------
class ArtworkCover extends StatelessWidget {
  final Uint8List? bytes;
  final IconData fallbackIcon;
  final double borderRadius;
  final double? size;
  final double? aspectRatio;
  final double iconSize;
  final Widget? overlay;

  const ArtworkCover({
    super.key,
    this.bytes,
    required this.fallbackIcon,
    this.borderRadius = AppRadius.inner, // 统一默认值
    this.size,
    this.aspectRatio = 1,
    this.iconSize = 26,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (bytes != null && bytes!.isNotEmpty) {
      content = Image.memory(
        bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      content = ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            fallbackIcon,
            size: iconSize,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [content, if (overlay != null) overlay!],
      ),
    );

    Widget cover = aspectRatio == null
        ? clipped
        : AspectRatio(aspectRatio: aspectRatio!, child: clipped);

    if (size != null) {
      cover = SizedBox(width: size, height: size, child: cover);
    }

    return cover;
  }
}

// ---------------------------------------------------------------------------
// MediaGridCard
// ---------------------------------------------------------------------------
class MediaGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Uint8List? coverBytes;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final Widget? badge;
  final Widget? trailing;
  final double? width;
  final int titleLines;
  final bool expandArtwork;
  final double? coverAspectRatio;
  final double contentSpacing;
  final EdgeInsetsGeometry padding;
  final MediaGridCardTextLayout textLayout;
  final int subtitleLines;

  const MediaGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.coverBytes,
    required this.fallbackIcon,
    this.onTap,
    this.badge,
    this.trailing,
    this.width,
    this.titleLines = 1,
    this.expandArtwork = false,
    this.coverAspectRatio = 1,
    this.contentSpacing = 10,
    this.padding = const EdgeInsets.all(8),
    this.textLayout = MediaGridCardTextLayout.below,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool useOverlay = textLayout == MediaGridCardTextLayout.overlay;

    TextStyle titleStyle = (theme.textTheme.titleSmall ?? const TextStyle())
        .copyWith(
          fontWeight: FontWeight.bold,
          color: useOverlay ? Colors.white : colorScheme.onSurface,
        );

    TextStyle subtitleStyle = (theme.textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          color: useOverlay ? Colors.white70 : colorScheme.onSurfaceVariant,
        );

    final titleWidget = Text(
      title,
      maxLines: titleLines,
      overflow: TextOverflow.ellipsis,
      style: titleStyle,
    );

    final subtitleWidget = Text(
      subtitle,
      maxLines: subtitleLines,
      overflow: TextOverflow.ellipsis,
      style: subtitleStyle,
    );

    Widget buildArtwork({required bool fillHeight}) {
      final cover = ArtworkCover(
        bytes: coverBytes,
        fallbackIcon: fallbackIcon,
        // 默认 AppRadius.inner，无需显式传值
        aspectRatio: (fillHeight || expandArtwork) ? null : coverAspectRatio,
        overlay: useOverlay
            ? _GradientOverlay(
                titleWidget: titleWidget,
                subtitleWidget: subtitleWidget,
              )
            : null,
      );

      return Stack(
        fit: (fillHeight || expandArtwork) ? StackFit.expand : StackFit.loose,
        children: [
          if (fillHeight || expandArtwork)
            Positioned.fill(child: cover)
          else
            cover,
          if (badge != null) Positioned(left: 8, top: 8, child: badge!),
          if (trailing != null) Positioned(right: 6, top: 6, child: trailing!),
        ],
      );
    }

    final card = AppPanel(
      onTap: onTap,
      padding: padding,
      // 使用默认 AppRadius.cardBR，无需显式传值
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;
          final artwork = buildArtwork(fillHeight: hasBoundedHeight);

          if (useOverlay) return artwork;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              hasBoundedHeight ? Expanded(child: artwork) : artwork,
              SizedBox(height: contentSpacing),
              titleWidget,
              const SizedBox(height: 2),
              subtitleWidget,
            ],
          );
        },
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}

/// 专用渐变遮罩，避免在 MediaGridCard 内堆砌匿名 Container。
class _GradientOverlay extends StatelessWidget {
  final Widget titleWidget;
  final Widget subtitleWidget;

  const _GradientOverlay({
    required this.titleWidget,
    required this.subtitleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // 使用 Colors.black54 / transparent 避免硬编码 withOpacity
          colors: [Colors.transparent, Colors.black54],
          stops: [0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [titleWidget, const SizedBox(height: 2), subtitleWidget],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SongListCardTile
// 用 ListTile 原生组件替代手动 Row；高亮状态由 selected + selectedTileColor 处理。
// ---------------------------------------------------------------------------
class SongListCardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Uint8List? coverBytes;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool highlighted;

  const SongListCardTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.coverBytes,
    required this.fallbackIcon,
    this.onTap,
    this.trailing,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      color: highlighted
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.tileBR),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: ArtworkCover(
          bytes: coverBytes,
          fallbackIcon: fallbackIcon,
          // 默认 AppRadius.inner，无需显式传值
          size: 44,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
            color: highlighted
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlighted
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QuickActionCard
// ---------------------------------------------------------------------------
class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      // 使用默认 AppRadius.cardBR，无需显式传值
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.innerBR,
            ),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppEmptyState
// ---------------------------------------------------------------------------
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 40 : 56,
                color: colorScheme.outlineVariant,
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppEmptySliver
// ---------------------------------------------------------------------------
class AppEmptySliver extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final bool hasScrollBody;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const AppEmptySliver({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.hasScrollBody = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: hasScrollBody,
      child: AppEmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
        action: action,
        padding: padding,
        compact: compact,
      ),
    );
  }
}
