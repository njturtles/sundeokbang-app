import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sundeokbang/constant/color.dart';
import 'package:sundeokbang/login/login_page.dart';
import 'package:sundeokbang/screen/usersettings/account_deletion_page.dart';
import 'package:sundeokbang/screen/usersettings/change_school_page.dart';
import 'package:sundeokbang/screen/usersettings/term_and_policy/Policy_webview_page.dart';
import 'package:sundeokbang/screen/usersettings/term_and_policy/terms_and_policy_page.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key});

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _decodedUserName = '';
  String _decodedUserSchool = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final settingJwttoken = await _storage.read(key: 'jwtToken');
      print('Token from storage: $settingJwttoken');
      print('----------------------------------------');

      if (settingJwttoken != null) {
        final decodedToken = JwtDecoder.decode(settingJwttoken);
        print('Decoded token: $decodedToken');

        setState(() {
          _decodedUserName = decodedToken['userName'] ?? '';
          _decodedUserSchool = decodedToken['university'] ?? '';
        });
      } else {
        print('No token found');
      }
    } catch (e) {
      print('Error loading or decoding token: $e');
    }
  }

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
            '내 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: UserInfoWidget(
                  userName: _decodedUserName,
                  userSchool: _decodedUserSchool,
                ),
              ),
              const Divider(color: Colors.black12, thickness: 1),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingOption(
                      Icons.school,
                      '학교 변경',
                      () => _navigateToPage(const ChangeSchoolPage()),
                    ),
                    const SizedBox(height: 20.0),
                    _buildSettingOption(
                      Icons.campaign,
                      '공지사항',
                      () => _navigateToPage(const PolicyWebviewpage(
                          url: 'https://www.naver.com')), // 임의 URL
                    ),
                    const SizedBox(height: 20.0),
                    _buildSettingOption(
                      Icons.article_outlined,
                      '약관 및 정책',
                      () => _navigateToPage(const TermsAndPolicyPage()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _logout, // 로그아웃 버튼 클릭 시 호출
                style: ElevatedButton.styleFrom(
                  foregroundColor: OrangeColor,
                  backgroundColor: WhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: OrangeColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  splashFactory: NoSplash.splashFactory,
                ),
                icon: const Icon(Icons.logout, color: OrangeColor),
                label: const Text(
                  '로그아웃',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AccountDeletionPage()), // 계정 탈퇴 페이지로 이동
                      );
                    },
                    child: const Text(
                      '회원 탈퇴',
                      style: TextStyle(
                        fontSize: 12,
                        color: GrayColor,
                        decoration: TextDecoration.underline,
                        decorationColor: GrayColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 24.0, color: GrayColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF646464)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    // 페이지에서 돌아왔을 때 토큰을 다시 불러와 UI 갱신
    _loadToken();
  }

  Future<void> _logout() async {
    try {
      // 토큰 삭제
      await _storage.delete(key: 'jwtToken');

      // 토큰 삭제 후 확인
      final deletedToken = await _storage.read(key: 'jwtToken');

      // 삭제된 토큰이 null인 경우 삭제가 성공적으로 이루어진 것
      if (deletedToken == null) {
        print('토큰이 성공적으로 삭제되었습니다.');
      } else {
        print('토큰 삭제 실패: 삭제된 토큰이 아직 존재합니다.');
      }

      // 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // 로그인 페이지로 이동
      );
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}

class UserInfoWidget extends StatelessWidget {
  final String userName;
  final String userSchool;

  const UserInfoWidget({super.key, 
    required this.userName,
    required this.userSchool,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.account_circle, size: 50, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userSchool,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
