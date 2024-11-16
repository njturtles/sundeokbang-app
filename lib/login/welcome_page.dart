import 'package:flutter/material.dart';
import 'package:sundeokbang/constant/color.dart';
import 'package:sundeokbang/screen/home/home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // 로고 이미지
            Align(
              alignment: const Alignment(0.0, -0.8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 150, // 원하는 너비
                height: 150, // 원하는 높이
              ),
            ),
            Align(
              alignment: const Alignment(0.0, -0.2),
              child: Image.asset(
                'assets/images/check.png',
                width: 150, // 원하는 너비
                height: 150, // 원하는 높이
              ),
            ),
            const Align(
              alignment: Alignment(0.0, 0.2),
              child: Text(
                '회원가입 성공!',
                style: TextStyle(
                  fontSize: 36,
                  color: OrangeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.0, 0.32),
              child: Text(
                '순덕방 회원가입이 완료되었습니다.',
                style: TextStyle(
                  color: GrayColor,
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.0, 0.4),
              child: Text(
                '여러분의 방 찾기를 도와드릴게요!',
                style: TextStyle(
                  color: GrayColor,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, 0.8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrangeColor,
                  foregroundColor: WhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 120),
                  splashFactory: NoSplash.splashFactory, // 회색 물결 효과 없애기
                ),
                child: const Text(
                  '메인화면 이동',
                  style: TextStyle(fontSize : 18 ,fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
