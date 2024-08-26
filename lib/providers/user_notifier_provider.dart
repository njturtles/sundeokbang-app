import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sundeokbang/models/kakao_user.dart';

final UserProvider =
    StateNotifierProvider<UserNotifier, UsersModel>((ref) => UserNotifier());

class UserNotifier extends StateNotifier<UsersModel> {
  UserNotifier()
      : super(UsersModel(
          userId: 0,
          userName: '',
          university: '',
          latitude: '',
          longitude: '',
        ));

  void updateUser({
    int? userId,
    String? userName,
    String? university,
    String? latitude,
    String? longitude,
  }) {
    state = UsersModel(
      userId: userId ?? state.userId,
      userName: userName ?? state.userName,
      university: university ?? state.university,
      latitude: latitude ?? state.latitude,
      longitude: longitude ?? state.longitude,
    );
  }

  void storeUserData(UsersModel data) {
    if (state.userId != data.userId) {
      state = UsersModel(
        userId: data.userId,
        userName: data.userName,
        university: data.university,
        latitude: data.latitude,
        longitude: data.longitude,
      );
    } else {
      return;
    }
  }
}
