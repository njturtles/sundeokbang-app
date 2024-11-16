import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TipPage extends StatelessWidget {
  final List<Map<String, String>> roomTips = [
    {
      'image': 'assets/images/tip1.png',
      'title': '원룸 종류와 장단점, 자취생들을 위한 꿀팁!',
      'description': '원룸의 다양한 종류와 장단점을 알아보세요.',
      'url': 'https://post.naver.com/viewer/postView.nhn?volumeNo=31577966&memberNo=41665055&vType=VERTICAL',
    },
    {
      'image': 'assets/images/tip2.PNG',
      'title': '원룸구하기 꿀팁 7가지',
      'description': '원룸을 구할 때 알아두면 좋은 꿀팁 7가지.',
      'url': 'https://blog.naver.com/eidnr148/223605863493',
    },
    {
      'image': 'assets/images/tip3.PNG',
      'title': '원룸꿀팁 알아봐요',
      'description': '자취생들을 위한 다양한 원룸 꿀팁을 확인하세요.',
      'url': 'https://blog.naver.com/cleanworlds/223562761392',
    },
  ];

  TipPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('원룸 꿀팁'),
      ),
      body: ListView.builder(
        itemCount: roomTips.length,
        itemBuilder: (context, index) {
          final tip = roomTips[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TipWebView(
                    url: tip['url']!,
                    title: tip['title']!,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image.asset(
                      tip['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tip['description']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TipWebView extends StatefulWidget {
  final String url;
  final String title;

  const TipWebView({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  _TipWebViewState createState() => _TipWebViewState();
}

class _TipWebViewState extends State<TipWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
