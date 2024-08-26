import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sundeokbang/models/sign_up_user.dart';

enum SignUpState { initial, loading, success, error }

class SignUpStateNotifier extends StateNotifier<SignUpState> {
  final FlutterSecureStorage _storage;
  String? _jwtToken;

  SignUpStateNotifier(this._storage) : super(SignUpState.initial) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _jwtToken = await _storage.read(key: 'jwtToken');
      if (_jwtToken == null) {
        print('스토리지에서 토큰을 읽어오지 못했습니다.');
      } else {
        print('읽어온 토큰: $_jwtToken');
      }
    } catch (e) {
      print('토큰 읽기 실패: $e');
    }
  }

  Future<void> signUp(User user) async {
    final dio = Dio();
    final apiUrl = dotenv.env['SIGN_UP_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      state = SignUpState.error;
      print('API URL이 설정되어 있지 않습니다.');
      return;
    }

    await _initialize();
    if (_jwtToken == null) {
      state = SignUpState.error;
      print('JWT 토큰이 없습니다.');
      return;
    }

    state = SignUpState.loading;

    try {
      final response = await dio.post(
        apiUrl,
        data: {
          "name": user.name,
          "university": user.university,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print({"name": user.name, "university": user.university});
      print('${response.statusCode}, ${response.data}');

      final newToken = response.data['result'];
      if (newToken != null) {
        await _storage.write(key: 'jwtToken', value: newToken);
        print('새 JWT 토큰이 스토리지에 저장되었습니다.');
        state = SignUpState.success;
      } else {
        state = SignUpState.error;
        print('응답 데이터에서 JWT 토큰을 찾을 수 없습니다.');
      }
    } catch (e) {
      state = SignUpState.error;
      print('회원가입 요청 실패: $e');
    }
  }
}
