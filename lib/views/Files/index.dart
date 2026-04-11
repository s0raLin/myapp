import 'dart:io';
import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  var _isLoading = false;
  List<File> _musicFiles = [];
  List<Tag?> _tags = [];

  Future pickDirectory() async {
    //弹窗
    final selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _isLoading = true;
      });

      //遍历选中的目录
      final directory = Directory(selectedDirectory);
      final List<FileSystemEntity> entities = await directory
          .list(recursive: false)
          .toList();

      final List<File> files = entities.whereType<File>().where((file) {
        final mimeType = lookupMimeType(file.path);
        return mimeType != null && mimeType.startsWith("audio/");
      }).toList();

      // 生成一个Future列表
      Iterable<Future<Tag?>> tagFutures = files.map((file) {
        return AudioTags.read(file.path);
      });

      //使用Future.wait等待所有操作完成
      List<Tag?> resolvedTags = await Future.wait(tagFutures);

      setState(() {
        _musicFiles = files;
        _tags = resolvedTags;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_musicFiles.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  Text("文件夹为空"),
                ],
              ),
            ),
          GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _musicFiles.length,
            itemBuilder: (context, index) {
              final file = _musicFiles[index];

              //提取文件名
              final fileName = p.basename(file.path);

              return FutureBuilder(
                future: AudioTags.read(file.path),
                builder: (context, snapshot) {
                  final tag = snapshot.data;
                  final bytes = (tag?.pictures.isNotEmpty ?? false)
                      ? tag!.pictures.first.bytes
                      : null;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: colorScheme.primary.withOpacity(0.1),
                              
                              child: bytes != null
                                  ? Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const Icon(Icons.music_note, size: 50),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tag?.title ?? fileName, //有标题显示标题,没有标题显示文件名
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: pickDirectory,
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
