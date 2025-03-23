// class StudentModel {
//   final String uid;
//   final String name;
//   final String email;
//
//   StudentModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//   });
//
//   factory StudentModel.fromMap(Map<String, dynamic> data, String uid) {
//     return StudentModel(
//       uid: uid,
//       name: data['name'] ?? '',
//       email: data['email'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'name': name,
//       'email': email,
//     };
//   }
// }
