import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sundeokbang/login/login_page.dart';
import 'package:sundeokbang/screen/home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _logoAnimation;
  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage(); // Secure Storage 인스턴스 생성

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 불투명도 애니메이션 설정
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // 로고 이동 애니메이션 설정
    _logoAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    // 애니메이션 시작
    _controller.forward();

    // 애니메이션 완료 시 사용자 정보 확인
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkUserLoggedIn();
      }
    });
  }

  // 사용자 정보 확인 메서드
  void _checkUserLoggedIn() async {
    String? token = await _secureStorage.read(key: 'jwtToken');

    if (token != null && token.isNotEmpty) {
      // 토큰 디코딩
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (decodedToken.containsKey('userName') &&
          decodedToken.containsKey('university')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SlideTransition(
              position: _logoAnimation,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
