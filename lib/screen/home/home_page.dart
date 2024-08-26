import 'package:flutter/material.dart';
import 'package:sundeokbang/screen/usersettings/user_setting_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('메인 화면', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSettingPage()),
                );
              },
              child: const Text('사용자 설정 버튼(임시)'),
            ),
          ],
        ),
      ),
    );
  }
}
