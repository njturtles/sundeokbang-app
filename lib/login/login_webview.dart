import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sundeokbang/login/sign_up_page.dart';
import 'package:sundeokbang/providers/user_notifier_provider.dart';
import 'package:sundeokbang/screen/home/home_page.dart';
import 'package:flutter/services.dart';

class LoginWebview extends ConsumerStatefulWidget {
  final String url;

  const LoginWebview({super.key, required this.url});

  @override
  ConsumerState<LoginWebview> createState() => _LoginWebviewState();
}

class _LoginWebviewState extends ConsumerState<LoginWebview> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late String redirectUrl;

  @override
  void initState() {
    super.initState();
    _loadRedirectUrl();
  }

  Future<void> _loadRedirectUrl() async {
    await dotenv.load(fileName: ".env");
    redirectUrl = dotenv.env['LOGIN_URL']!;

    if (redirectUrl.isEmpty) {
      _showErrorAndExit('LOGIN_URL 환경 변수가 설정되지 않았습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("로그인"),
        ),
        body: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            if (url != null &&
                redirectUrl.isNotEmpty &&
                url.toString().contains(redirectUrl)) {
              try {
                String pageContent = await controller.evaluateJavascript(
                    source: "document.body.innerText");
                if (pageContent.trim().startsWith('{') &&
                    pageContent.trim().endsWith('}')) {
                  try {
                    var jsonResponse = json.decode(pageContent);
                    if (jsonResponse['result'] != null) {
                      String jwtToken = jsonResponse['result'];
                      if (JwtDecoder.isExpired(jwtToken)) {
                        handleUserNotLoggedIn(context);
                      } else {
                        await secureStorage.write(
                            key: 'jwtToken', value: jwtToken);
                        final decodedUser = JwtDecoder.decode(jwtToken);
                        updateUser(decodedUser);
                        navigateBasedOnUser(context, decodedUser['userName']);
                      }
                    } else {
                      handleUserNotLoggedIn(context);
                    }
                  } catch (e) {
                    _showErrorAndExit('토큰을 처리하는 중 오류가 발생했습니다.');
                  }
                } else {
                  _showErrorAndExit('잘못된 응답 형식입니다.');
                }
              } catch (e) {
                _showErrorAndExit('웹 페이지를 처리하는 중 오류가 발생했습니다.');
              }
            }
          },
        ),
      ),
    );
  }

  void updateUser(Map<String, dynamic> decodedUser) {
    ref.read(UserProvider.notifier).updateUser(
          userId: decodedUser['userId'] ?? 0,
          userName: decodedUser['userName'] ?? '',
          university: decodedUser['university'],
          latitude: decodedUser['latitude'],
          longitude: decodedUser['longitude'],
        );
  }

  void handleUserNotLoggedIn(BuildContext context) {
    ref.read(UserProvider.notifier).updateUser(
          userId: 0,
          userName: '',
        );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  void navigateBasedOnUser(BuildContext context, String? userName) {
    final route = (userName != null && userName.isNotEmpty)
        ? MaterialPageRoute(builder: (context) => const HomePage())
        : MaterialPageRoute(builder: (context) => const SignUpPage());

    Navigator.pushReplacement(context, route);
  }

  void _showErrorAndExit(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('서버 오류'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // 앱 종료
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
