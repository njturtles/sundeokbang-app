import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sundeokbang/login/login_page.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  bool isCheckBoxChecked = false; // 체크박스 상태를 저장하는 변수
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '회원 탈퇴',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: '회원탈퇴 시, 다음과 같은 내용이 삭제됩니다.\n또한 삭제된 내용은 복구가 ',
                    ),
                    TextSpan(
                      text: '불가능',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '합니다.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // 추가적인 공백
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '• 회원 이메일, 비밀번호\n• 방 즐겨찾기 정보',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isCheckBoxChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isCheckBoxChecked = value ?? false;
                      });
                    },
                    activeColor: Colors.orange,
                    checkColor: Colors.white,
                  ),
                  Text(
                    '위의 내용을 숙지하였고, 회원 탈퇴에 동의합니다.',
                    style: TextStyle(
                      color: isCheckBoxChecked ? Colors.orange : Colors.grey,
                      decorationColor:
                          isCheckBoxChecked ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: isCheckBoxChecked
                      ? () async {
                          await _deleteAccount();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // 3. 버튼 색상 주황색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 3. 테두리 사각형
                    ),
                  ), // 체크박스가 체크되지 않았을 때는 버튼을 비활성화
                  child: const Text(
                    '회원탈퇴',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // 1. 스토리지에서 JWT 토큰 불러오기
      final jwtToken = await _storage.read(key: 'jwtToken');
      if (jwtToken == null) {
        throw Exception("JWT 토큰을 찾을 수 없습니다.");
      }

      // 2. 서버에 계정 삭제 요청 보내기
      final dio = Dio();
      final apiUrl = dotenv.env['DELETE_URL']; // 계정 삭제 API URL

      if (apiUrl == null || apiUrl.isEmpty) {
        throw Exception('.env 파일에 설정되지 않았습니다.');
      }

      final response = await dio.delete(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // 서버 응답 디버깅
      print('Server response: ${response.data}');
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 3. 계정 삭제 성공 시 스토리지에서 JWT 토큰 삭제
        await _storage.delete(key: 'jwtToken');

        String? tokenAfterDelete = await _storage.read(key: 'jwtToken');
        if (tokenAfterDelete == null) {
          // 토큰이 삭제되었다면 성공 메시지 출력
          print('Token successfully deleted');
        } else {
          // 토큰이 여전히 존재한다면 실패 메시지 출력
          print('Token deletion failed');
        }

        // 4. 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()), // 로그인 페이지로 이동
        );
      } else {
        print('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
