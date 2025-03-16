import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/assign_teacher_provider.dart';

class AssignTeacherScreen extends StatelessWidget {
  const AssignTeacherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Teacher Role')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select a user to assign as a teacher:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// **📌 StreamBuilder for real-time user list**
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: teacherProvider.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                final users = snapshot.data ?? [];

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: users.any((user) => user['id'] == teacherProvider.selectedUserId)
                          ? teacherProvider.selectedUserId
                          : null,
                      hint: const Text('Select a user'),
                      onChanged: users.isNotEmpty
                          ? (userId) {
                        if (userId == null) {
                          teacherProvider.selectUser('', '', '');
                          return;
                        }
                        final selectedUser = users.firstWhere((user) => user['id'] == userId);
                        teacherProvider.selectUser(
                          userId,
                          selectedUser['name'],
                          selectedUser['email'],
                        );
                      }
                          : null,
                      items: users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['id'],
                          child: Text('${user['name']} (${user['email']})'),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select a user' : null,
                    ),

                    const SizedBox(height: 16),

                    if (snapshot.connectionState == ConnectionState.waiting)
                      const CircularProgressIndicator()
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            /// **📌 Display Selected User Info**
            if (teacherProvider.selectedUserName != null && teacherProvider.selectedUserEmail != null)
              Column(
                children: [
                  Text("Name: ${teacherProvider.selectedUserName}", style: const TextStyle(fontSize: 16)),
                  Text("Email: ${teacherProvider.selectedUserEmail}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                ],
              ),

            /// **📌 Photo Picker**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                teacherProvider.selectedImageFile == null
                    ? const Text('No image selected')
                    : Image.file(
                  teacherProvider.selectedImageFile!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      teacherProvider.pickImage(File(picked.path));
                    }
                  },
                  child: const Text('Pick Photo'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// **📌 Submit Button**
            teacherProvider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => teacherProvider.assignTeacher(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Assign as Teacher",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
