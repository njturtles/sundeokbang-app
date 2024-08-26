
class User {
  final String name;
  final String university;

  User({required this.name, required this.university});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'university': university,
    };
  }
}
