import 'package:flutter/material.dart';
import 'package:sundeokbang/screen/usersettings/term_and_policy/policy_page.dart';
import 'package:sundeokbang/screen/usersettings/term_and_policy/term_page.dart';

class TermsAndPolicyPage extends StatelessWidget {
  const TermsAndPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약관 및 정책'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsPage()),
                  );
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  overlayColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                ),
                child: const Row(
                  children: [
                    Text('이용약관', style: TextStyle(fontSize: 16.0)),
                    Spacer(), // Spacer를 사용하여 간격 조정
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage()),
                  );
                },
                style: ButtonStyle(
                  foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.black),
                  overlayColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                ),
                child: const Row(
                  children: [
                    Text('개인정보처리방침', style: TextStyle(fontSize: 16.0)),
                    Spacer(), // Spacer를 사용하여 간격 조정
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
