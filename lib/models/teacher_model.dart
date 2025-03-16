class TeacherModel {
  final String uid;
  final String name;
  final String email;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> data, String uid) {
    return TeacherModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }
}
