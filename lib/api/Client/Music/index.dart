import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class MusicApi {
  static final Dio _dio = Dio();

  static Future<void> pickAndUploadMusic() async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio, //限制只能选音频
    );

    if (result == null && result?.files.single.path == null) {
      return;
    }
    final filePath = result?.files.single.path!;
    final fileName = result?.files.single.name;

    FormData formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(filePath!, filename: fileName),
      "title": "我的歌曲", // 还可以带上其他字段
    });

    final response = await _dio.post(
      "http://localhost:8080/api/music",
      data: formData,
      onSendProgress: (int sent, int total) {
        // 这里可以计算进度：(sent / total * 100).toStringAsFixed(0)%
        print("上传进度: ${(sent / total * 100).round()}%");
      },
    );

    if (response.statusCode == 200) {
      print("上传成功: ${response.data}");
    } else {
      print("上传失败");
    }
  }
}
