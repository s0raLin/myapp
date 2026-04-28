import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:myapp/api/model/ApiResponse/index.dart';
import 'package:myapp/api/model/User/index.dart';

class UserApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://localhost:8080/api/auth/"),
  );

  static Future<User?> login({
    required String username,
    required String password,
  }) async {
    // final formData = FormData.fromMap({
    //   "username": username,
    //   "password": password,
    // });
    final response = await _dio.post(
      "/login",
      data: {"username": username, "password": password},
    );

    final result = ApiResponse.fromJson(response.data);
    if (result.code == 0) {
      String? token = result.data?['token'];
      final storage = FlutterSecureStorage();
      storage.write(key: "jwt_key", value: token);

      final user = User.fromJson(result.data?["user"]);
      user.token = token;
      return user;
    } else {
      return null;
    }
  }

  static Future<Response> register({
    required String username,
    required String password,
    required String email,
    Uint8List? avatarBytes,
  }) async {
    final formData = FormData.fromMap({
      "username": username,
      "password": password,
      "email": email,
      if (avatarBytes != null)
        "avatar": MultipartFile.fromBytes(
          avatarBytes,
          filename: "${username}_avatar.jpg",
        ),
    });

    final response = await _dio.post(
      "/register",
      data: formData,
      onSendProgress: (sent, total) {
        print("上传进度: ${(sent / total * 100).toStringAsFixed(0)}");
      },
    );

    return response;
  }
}
