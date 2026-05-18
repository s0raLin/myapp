import 'package:flutter/material.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/views/MusicDetail/widgets/narrow_layout.dart';
import 'package:myapp/views/MusicDetail/widgets/wide_layout.dart';
import 'package:provider/provider.dart';

// ─── 主页面 ───────────────────────────────────────────────────────────────────

class MusicDetailPage extends StatefulWidget {
  final MusicInfo music;
  const MusicDetailPage({super.key, required this.music});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  @override
  Widget build(BuildContext context) {

    final isLiked = context.select<MusicProvider, bool>(
      (p) => p.favList.any((m) => m.id == widget.music.id),
    );
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return isWide
        ? WideLayout(music: widget.music, isLiked: isLiked)
        : NarrowLayout(music: widget.music, isLiked: isLiked);
  }
}
