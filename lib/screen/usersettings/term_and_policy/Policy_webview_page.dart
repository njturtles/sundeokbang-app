import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PolicyWebviewpage extends StatefulWidget {
  final String url;

  const PolicyWebviewpage({super.key, required this.url});

  @override
  State<PolicyWebviewpage> createState() => _PolicyWebviewpageState();
}

class _PolicyWebviewpageState extends State<PolicyWebviewpage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
      ),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      ),
    );
  }
}
