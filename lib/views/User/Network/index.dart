import 'package:flutter/material.dart';
import 'package:myapp/api/Client/Music/index.dart';
import 'package:myapp/api/Model/Music/index.dart';

class NetWorkPage extends StatefulWidget {
  const NetWorkPage({super.key});

  @override
  State<NetWorkPage> createState() => _NetWorkPageState();
}

class _NetWorkPageState extends State<NetWorkPage> {
  List<Music> musics = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text("网络")),
          SliverToBoxAdapter(
            child: Center(
              child: TextButton(
                onPressed: () async {
                  musics = await MusicApi.listMusic();
                },
                child: Text("获取"),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: musics.length,
            itemBuilder: (context, index) {
              final music = musics[index];
              return ListTile(
                leading: music.coverUrl != null && music.coverUrl!.isNotEmpty
                    ? ImageIcon(NetworkImage(music.coverUrl!))
                    : Icon(Icons.music_note_rounded),
                title: Text(music.title),
                subtitle: Text("${music.artist}-${music.album}"),
              );
            },
          ),
        ],
      ),
    );
  }
}
