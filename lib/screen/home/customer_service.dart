import 'package:flutter/material.dart';


class CustomerServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '고객센터',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true, // 제목 가운데 정렬
        backgroundColor: Colors.white,
        elevation: 1.0, // 그림자 효과
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 동작
          },
        ),
      ),
      body: const Center(
        child: Text(
          '서비스 준비 중입니다.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
