import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MusicDetailPage extends StatefulWidget {
  final String? id;
  const MusicDetailPage({super.key, required this.id});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text("${widget.id}"),
      ),
      body: Center(child: Text("MusicDetail ${widget.id}")),
    );
  }
}
