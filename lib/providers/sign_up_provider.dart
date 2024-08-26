import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sundeokbang/models/sign_up_state.dart';

final signUpProvider = StateNotifierProvider<SignUpStateNotifier, void>((ref) {
  return SignUpStateNotifier(const FlutterSecureStorage());
});
