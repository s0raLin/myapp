import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

enum MediaGridCardTextLayout { below, overlay }

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
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
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
    final radius = borderRadius ?? BorderRadius.circular(24);

    return Card.filled(
      margin: EdgeInsets.zero,
      color: color ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ArtworkCover extends StatelessWidget {
  final Uint8List? bytes;
  final IconData fallbackIcon;
  final double borderRadius;
  final double? size;
  final double? aspectRatio;
  final double iconSize;
  final Widget? overlay;
  final List<Color>? gradientColors;

  const ArtworkCover({
    super.key,
    this.bytes,
    required this.fallbackIcon,
    this.borderRadius = 20,
    this.size,
    this.aspectRatio = 1,
    this.iconSize = 34,
    this.overlay,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors =
        gradientColors ??
        [colorScheme.primaryContainer, colorScheme.secondaryContainer];

    Widget content;
    if (bytes != null && bytes!.isNotEmpty) {
      content = Image.memory(
        bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      content = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: iconSize,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(fit: StackFit.expand, children: [content, ?overlay]),
    );

    final cover = aspectRatio == null
        ? clipped
        : AspectRatio(aspectRatio: aspectRatio!, child: clipped);

    if (size == null) return cover;

    return SizedBox(width: size, height: size, child: cover);
  }
}

class MediaGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Uint8List? coverBytes;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final Widget? badge;
  final Widget? trailing;
  final double? width;
  final double titleLines;
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
    this.contentSpacing = 12,
    this.padding = const EdgeInsets.all(10),
    this.textLayout = MediaGridCardTextLayout.below,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool useOverlayText = textLayout == MediaGridCardTextLayout.overlay;

    final titleWidget = Text(
      title,
      maxLines: titleLines.toInt(),
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: useOverlayText ? colorScheme.onInverseSurface : null,
      ),
    );

    final subtitleWidget = Text(
      subtitle,
      maxLines: subtitleLines,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: useOverlayText
            ? colorScheme.onInverseSurface.withValues(alpha: 0.78)
            : colorScheme.onSurfaceVariant,
      ),
    );

    Widget buildArtwork({required bool fillHeight}) {
      final cover = ArtworkCover(
        bytes: coverBytes,
        fallbackIcon: fallbackIcon,
        borderRadius: 22,
        aspectRatio: fillHeight || expandArtwork ? null : coverAspectRatio,
        iconSize: 42,
        overlay: useOverlayText
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.26),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              titleWidget,
                              const SizedBox(height: 2),
                              subtitleWidget,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      );

      return Stack(
        fit: fillHeight || expandArtwork ? StackFit.expand : StackFit.loose,
        children: [
          if (fillHeight || expandArtwork) Positioned.fill(child: cover) else cover,
          if (badge != null) Positioned(left: 10, top: 10, child: badge!),
          if (trailing != null) Positioned(right: 8, top: 8, child: trailing!),
        ],
      );
    }

    final card = AppPanel(
      onTap: onTap,
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool hasBoundedHeight = constraints.maxHeight.isFinite;
          final artwork = buildArtwork(fillHeight: hasBoundedHeight);

          if (useOverlayText) return artwork;

          if (hasBoundedHeight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: artwork),
                SizedBox(height: contentSpacing),
                titleWidget,
                const SizedBox(height: 2),
                subtitleWidget,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              artwork,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppPanel(
      onTap: onTap,
      color: highlighted
          ? colorScheme.secondaryContainer.withValues(alpha: 0.95)
          : colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, maxWidth: 64),
            child: ArtworkCover(
              bytes: coverBytes,
              fallbackIcon: fallbackIcon,
              borderRadius: 16,
              size: 56,
              iconSize: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

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
    const double leadingInset = 2;

    return AppPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: leadingInset),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.onPrimaryContainer),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: leadingInset),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: leadingInset),
              child: Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 72 : 88,
                height: compact ? 72 : 88,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(compact ? 22 : 28),
                ),
                child: Icon(
                  icon,
                  size: compact ? 34 : 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: compact ? 18 : 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
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
