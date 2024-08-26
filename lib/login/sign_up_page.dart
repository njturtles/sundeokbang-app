import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sundeokbang/login/welcome_page.dart';
import 'package:sundeokbang/models/sign_up_user.dart';
import 'package:sundeokbang/providers/sign_up_provider.dart';
import 'dart:io'; // For exit()

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _termsChecked = false;
  bool _privacyChecked = false;
  String _nameError = '';
  String _dropdownError = '';
  String _termsError = '';
  String _privacyError = '';
  List<String> _dropdownItems = [];
  bool _hasFetchedItems = false;
  bool _isSubmitting = false;
  String? _selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    _fetchDropdownItems();
  }

  Future<void> _fetchDropdownItems() async {
    if (!_hasFetchedItems) {
      try {
        final items = await _getItemsFromServer();
        if (mounted) {
          setState(() {
            _dropdownItems = items;
            _hasFetchedItems = true;
          });
        }
      } catch (e) {
        _showErrorDialog('데이터 로드 실패', '드롭다운 항목을 불러오는 데 실패했습니다.');
      }
    }
  }

  Future<List<String>> _getItemsFromServer() async {
    await Future.delayed(const Duration(seconds: 1)); // 모의 대기 시간
    return ['순천대학교'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
                _buildInputField(
                  label: '이름',
                  controller: _nameController,
                  errorMessage: _nameError,
                  keyboardType: TextInputType.text,
                ),
                _buildDropdown(),
                _buildCheckbox(
                  label: '서비스 이용 약관 (필수)',
                  checked: _termsChecked,
                  onChanged: (value) =>
                      setState(() => _termsChecked = value ?? false),
                  errorMessage: _termsError,
                ),
                _buildCheckbox(
                  label: '개인정보처리방침(필수)',
                  checked: _privacyChecked,
                  onChanged: (value) =>
                      setState(() => _privacyChecked = value ?? false),
                  errorMessage: _privacyError,
                ),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String errorMessage,
    required TextInputType keyboardType,
    bool isObscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscure,
            onChanged: (value) => _validateInput(label, value),
            decoration: InputDecoration(
              hintText: '정보를 입력해주세요.',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16.0),
              border: _buildBorder(),
              focusedBorder: _buildBorder(color: Colors.orange),
              enabledBorder: _buildBorder(color: Colors.orange),
              errorBorder: _buildBorder(color: Colors.redAccent),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              errorText: errorMessage.isNotEmpty ? errorMessage : null,
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder({Color color = Colors.orange}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('학교 선택'),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _showDropdownSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _dropdownError.isNotEmpty
                      ? Colors.redAccent
                      : Colors.orange,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDropdownValue ?? '학교를 선택하세요.',
                    style: TextStyle(
                      color: _selectedDropdownValue == null
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_dropdownError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 22),
              child: Text(_dropdownError,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _showDropdownSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.2,
          maxChildSize: 0.4,
          minChildSize: 0.2,
          expand: false,
          builder: (context, scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: _dropdownItems.length,
              itemBuilder: (context, index) {
                final item = _dropdownItems[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      _selectedDropdownValue = item;
                      _dropdownError = '';
                    });
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool checked,
    required ValueChanged<bool?> onChanged,
    required String errorMessage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: onChanged,
                activeColor: Colors.orange,
                side: const BorderSide(color: Colors.grey, width: 2.0),
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: checked ? Colors.orange : Colors.grey,
                    decorationColor:
                        checked ? Colors.orange : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onSignUpButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 150),
          splashFactory: NoSplash.splashFactory,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('회원가입', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _validateInput(String label, String value) {
    setState(() {
      if (label == '이름') {
        _nameError = _getNameError(value);
      }
    });
  }

  String _getNameError(String value) {
    if (value.isEmpty) {
      return '이름을 입력하세요.';
    } else if (!RegExp(r'^[가-힣a-zA-Z]*$').hasMatch(value)) {
      return '한글이나 영문자만 입력하세요.';
    } else if (value.length < 2) {
      return '이름은 최소 2글자 이상이어야 합니다.';
    } else {
      return '';
    }
  }

  Future<void> _onSignUpButtonPressed() async {
    _validateInput('이름', _nameController.text);

    if (_nameError.isEmpty &&
        _termsChecked &&
        _privacyChecked &&
        _selectedDropdownValue != null) {
      setState(() {
        _isSubmitting = true;
      });

      final user = User(
        name: _nameController.text,
        university: _selectedDropdownValue!,
      );

      try {
        await ref.read(signUpProvider.notifier).signUp(user);
        if (mounted) {
          _navigateToWelcomePage();
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          _showErrorDialog('회원가입 실패', '회원가입 도중 오류가 발생했습니다.', isExit: true);
        }
      }
    } else {
      _updateErrors();
    }
  }

  void _updateErrors() {
    setState(() {
      _dropdownError = _selectedDropdownValue == null ? '학교를 선택하세요.' : '';
      _termsError = !_termsChecked ? '서비스 이용 약관에 동의해야 합니다.' : '';
      _privacyError = !_privacyChecked ? '개인정보처리방침에 동의해야 합니다.' : '';
    });
  }

  void _navigateToWelcomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void _showErrorDialog(String title, String content, {bool isExit = false}) {
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
                if (isExit) {
                  Future.delayed(Duration.zero, () => exit(0)); // 앱 종료
                }
              },
            ),
          ],
        );
      },
    );
  }
}
