import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthKakao {
  static Future<Response> authKakao() async {
    await dotenv.load(fileName: ".env");
    String? apiKey = dotenv.env['API_KEY'];
    if (apiKey == null) {
      throw Exception('API_KEY 환경 변수가 설정되지 않았습니다.');
    }
    final res = await Dio().get('$apiKey/v1/auth/oauth/kakao');
    return res;
  }
}
