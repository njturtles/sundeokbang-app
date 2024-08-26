class UsersModel {
  final int userId;
  final String userName;
  final String university;
  final String latitude;
  final String longitude;

  UsersModel({
    required this.userId,
    required this.userName,
    required this.university,
    required this.longitude,
    required this.latitude,
  });

  UsersModel.fromJson({required Map<String, dynamic> json})
      : userId = json['userId'] ?? 0,
        userName = json['userName'] ?? '',
        university = json['university'] ?? '',
        latitude = json['latitude'] ?? '',
        longitude = json['longitude'] ?? '';
}
