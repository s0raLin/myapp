import 'package:myapp/model/Playlist/index.dart';
import 'package:myapp/utils/NetEaseCloud/index.dart';

class NeteaseCloudMusicApi {
  static Future<List<Playlist>> getPlaylist(String userId) async {
    final response = await NeteaseCloudUtil().get("/user/playlist?uid=$userId");

    final data = response.data;
    final List<dynamic> playlistJsonList = data["playlist"] ?? [];

    return playlistJsonList
        .map((item) => Playlist.fromNeteaseJson(item))
        .toList();
  }
}
