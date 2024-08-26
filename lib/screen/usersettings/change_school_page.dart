import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sundeokbang/constant/color.dart';

class ChangeSchoolPage extends StatefulWidget {
  const ChangeSchoolPage({super.key});

  @override
  _ChangeSchoolPageState createState() => _ChangeSchoolPageState();
}

class _ChangeSchoolPageState extends State<ChangeSchoolPage> {
  final List<String> schoolItems = ['순천대학교', '제일대학교'];
  String? selectedSchool;
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OrangeColor,
          title: const Text('학교 변경', style: TextStyle(color: WhiteColor)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '학교를 선택해주세요.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: DropdownButtonFormField2<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: GrayColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: OrangeColor, width: 3),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            hint: const Text('학교를 선택하세요.'),
                            items: schoolItems
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item,
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return '학교를 선택해주세요.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedSchool = value;
                              });
                              _formKey.currentState!.validate();
                            },
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: OrangeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: OrangeColor),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: OrangeColor),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '학교를 변경하면 새로운 설정이 적용됩니다.',
                                  style: TextStyle(
                                      color: OrangeColor, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrangeColor,
              foregroundColor: WhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              splashFactory: NoSplash.splashFactory,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _changeSchool();
              }
            },
            child: const Text('선택 완료'),
          ),
        ),
      ),
    );
  }

  Future<void> _changeSchool() async {
    try {
      // 1. 스토리지에서 JWT 토큰 불러오기
      String? jwtToken = await _storage.read(key: 'jwtToken');
      if (jwtToken == null) {
        throw Exception("JWT 토큰을 찾을 수 없습니다.");
      }

      // 2. 서버에 학교 변경 요청 보내기
      final dio = Dio();
      final apiUrl = dotenv.env['SIGN_UP_URL']; // 학교 업데이트 API URL

      // 디버깅을 위한 로그 출력
      print('Sending request with university: $selectedSchool');

      final response = await dio.post(
        apiUrl!,
        data: {'university': selectedSchool},
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json', // 명시적으로 JSON 형식 설정
          },
        ),
      );

      // 서버 응답 디버깅
      print('Server response: ${response.data}');
      print('Response status code: ${response.statusCode}');

      // 3. 서버에서 새로운 JWT 토큰을 반환하면 스토리지에 저장
      if (response.statusCode == 200) {
        final newJwtToken = response.data['result']; // 서버에서 반환된 새로운 JWT 토큰
        await _storage.write(key: 'jwtToken', value: newJwtToken);
        print('New JWT Token: $newJwtToken');
        Navigator.pop(context); // 페이지를 뒤로 가게 합니다.
      } else {
        // 서버 응답 코드가 200이 아닐 경우, 실패 처리
        _showErrorDialog('학교 변경 실패', '학교 변경에 실패했습니다.');
      }
    } catch (e) {
      // 예외 발생 시 다이얼로그를 보여줍니다.
      _showErrorDialog('오류 발생', '서버와의 통신 중 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 페이지를 뒤로 가게 합니다.
              },
            ),
          ],
        );
      },
    );
  }
}
