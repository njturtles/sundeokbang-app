import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관'),
      ),
      body: const Center(
        child: Text('이용약관 내용이 여기에 표시됩니다.'),
      ),
    );
  }
}
