import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // secure storage import
import 'home_page.dart'; // 메인 화면으로 이동하기 위해 import

class FindTabScreen extends StatefulWidget {
  final String token;

  const FindTabScreen({Key? key, required this.token}) : super(key: key);

  @override
  _FindTabScreenState createState() => _FindTabScreenState();
}

class _FindTabScreenState extends State<FindTabScreen> {
  WebViewController? _controller;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadJwtToken(); // JWT 토큰 로드 함수 호출
  }

  Future<void> _loadJwtToken() async {
    try {
      _token = await _secureStorage.read(key: 'jwtToken');
      print('Loaded token from storage: $_token');

      if (_token != null) {
        _initializeWebView(); // 웹뷰 초기화 후 쿠키 설정
      } else {
        print("JWT 토큰이 없습니다.");
      }
    } catch (e) {
      print("토큰 로드 오류: $e");
    }
  }

  void _initializeWebView() async {
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies(); // 기존 쿠키 삭제

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            print('페이지 시작: $url');
            await _setCookie(url, _token!); // 페이지 시작 시 쿠키 설정
          },
          onPageFinished: (String url) {
            print('페이지 로드 완료: $url');
          },
        ),
      );

    // 페이지 로드 전에 쿠키와 헤더 설정
    await _setCookie('https://borangkkae.com/map', _token!);
    _controller!.loadRequest(
      Uri.parse('https://borangkkae.com/map'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    setState(() {}); // 상태 업데이트
  }

  Future<void> _setCookie(String url, String token) async {
    try {
      final cookieManager = WebViewCookieManager();
      final cookie = WebViewCookie(
        name: 'user',
        value: token,
        domain: Uri.parse(url).host,
        path: '/',
      );
      await cookieManager.setCookie(cookie);
      print('쿠키 설정 완료: ${cookie.name} = ${cookie.value}');
    } catch (e) {
      print('쿠키 설정 오류: $e');
      _showErrorDialog('쿠키 설정 중 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _openChatbotWebView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('순덕방 챗봇'),
            backgroundColor: Colors.orange,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse('https://borangkkae.com/chatbot')),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' '),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Text(
            '<',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              height: 1.0,
            ),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          _controller != null
              ? WebViewWidget(controller: _controller!)
              : const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openChatbotWebView,
              child: Image.asset(
                'assets/images/chatbot_icon.png',
                width: 70,  // Adjust size if necessary
                height: 70,
              ),
            ),
          ),


        ],
      ),
    );
  }
}
