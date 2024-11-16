import 'package:flutter/material.dart';
import 'package:sundeokbang/api/authKakao.dart';
import 'package:sundeokbang/login/login_webview.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            // 로고 이미지
            Align(
              alignment: const FractionalOffset(0.5, 0.2),
              child: Image.asset(
                'assets/images/logo.png',
                width: 150, // 원하는 너비
                height: 150, // 원하는 높이
              ),
            ),
            // 가운데 버튼
            Align(
              alignment: const FractionalOffset(0.5, 0.6),
              child: GestureDetector(
                onTap: () async {
                  final res = await AuthKakao.authKakao();
                  final String url = res.realUri.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginWebview(
                        url: url,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 300, // 원하는 버튼 너비
                  height: 45, // 원하는 버튼 높이
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/kakao_login_button.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
