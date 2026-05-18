import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/config/globals.dart';

class MusicDashboardPage extends StatelessWidget {
  const MusicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 700;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.large(
                      pinned: true,
                      scrolledUnderElevation: 3.0, // 滚动时自动应用 M3 容器叠层色
                      leading: IconButton(
                        onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu_rounded),
                      ),
                      title: const Text("M3Music"),
                      actions: [
                        IconButton(
                          onPressed: () => context.push("/settings"),
                          icon: const Icon(Icons.settings_rounded),
                        ),
                      ],
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const _NowPlayingCard(),
                            const SizedBox(height: 16),

                            if (compact)
                              const Column(
                                children: [
                                  _PlaybackControlCard(),
                                  SizedBox(height: 16),
                                  _AudioInfoCard(),
                                  SizedBox(height: 16),
                                  _OutputDeviceCard(),
                                ],
                              )
                            else
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _PlaybackControlCard()),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _AudioInfoCard(),
                                        SizedBox(height: 16),
                                        _OutputDeviceCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatefulWidget {
  const _NowPlayingCard();

  @override
  State<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<_NowPlayingCard> {
  double progress = 0.45;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card.filled(
      color: colorScheme.secondaryContainer,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(
          colorScheme: colorScheme.copyWith(
            onSurface: colorScheme.onSecondaryContainer,
          ),
        ),
        child: InkWell(
          onTap: () => context.push("/dashboard/cover-flow"),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 500;

                final info = Expanded(
                  flex: compact ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NowPlayingInfo(theme: theme),
                      const SizedBox(height: 24),

                      _WaveProgressBar(
                        progress: progress,
                        onChanged: (value) {
                          setState(() {
                            progress = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            _formatTime(progress * 225),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "3:45",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                return compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AlbumCover(colorScheme: colorScheme),
                          const SizedBox(height: 24),
                          info,
                        ],
                      )
                    : Row(
                        children: [
                          _AlbumCover(colorScheme: colorScheme),
                          const SizedBox(width: 24),
                          info,
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }
}

class _AlbumCover extends StatelessWidget {
  final ColorScheme colorScheme;

  const _AlbumCover({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "album_cover",
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          // 使用 M3 容器色令牌，绝不硬编码透明度
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.album_rounded,
          size: 44,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _NowPlayingInfo extends StatelessWidget {
  final ThemeData theme;

  const _NowPlayingInfo({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NOW PLAYING",
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Blinding Lights",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "The Weeknd",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}

class _WaveProgressBar extends StatelessWidget {
  final double progress;
  final ValueChanged<double> onChanged;

  const _WaveProgressBar({required this.progress, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 完美的 M3 语义色彩映射
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outlineVariant; // 官方标准的未激活/边框 Token

    return SizedBox(
      height: 36,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 36,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
          overlayShape: SliderComponentShape.noOverlay,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(48, (index) {
                  final factor = [0.3, 0.5, 0.7, 0.9, 0.6, 0.4, 0.8][index % 7];
                  final active = index / 48 <= progress;

                  return Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 4,
                        height: 8 + (24 * factor),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active ? activeColor : inactiveColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Slider(value: progress, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _PlaybackControlCard extends StatelessWidget {
  const _PlaybackControlCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: colorScheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Playback",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                IconButton.filled(
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    fixedSize: const Size(64, 64),
                    iconSize: 32,
                  ),
                  icon: const Icon(Icons.pause_rounded),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioInfoCard extends StatelessWidget {
  const _AudioInfoCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: Icon(Icons.high_quality_rounded),
          title: Text("Audio Quality"),
          subtitle: Text("96kHz / 24bit"),
          trailing: FilledButton.tonal(onPressed: null, child: Text("Hi-Res")),
        ),
      ),
    );
  }
}

class _OutputDeviceCard extends StatelessWidget {
  const _OutputDeviceCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: Icon(Icons.bluetooth_audio_rounded),
          title: Text("Output Device"),
          subtitle: Text("LDAC Headphones"),
          trailing: Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
