import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/assign_student_provider.dart';

class AssignStudentScreen extends StatelessWidget {
  const AssignStudentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    // **Filter users based on search query**
    final filteredUsers = studentProvider.allUsers.where((user) {
      final name = user['name'].toLowerCase();
      final email = user['email'].toLowerCase();
      return name.contains(studentProvider.searchQuery) || email.contains(studentProvider.searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Student Role')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// **📌 Search Bar**
            TextField(
              decoration: InputDecoration(
                labelText: "Search by Name or Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: studentProvider.onSearchChanged,
            ),
            const SizedBox(height: 16),

            const Text(
              "Select users to assign as students:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// **📌 User List**
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(child: Text("No matching users found."))
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final isSelected = studentProvider.selectedUserIds.contains(user['id']);

                  return Card(
                    color: isSelected ? Colors.lightBlue.shade100 : Colors.white,
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () => studentProvider.pickImage(user['id']), // Pick image on tap
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: studentProvider.selectedUserPhotos.containsKey(user['id'])
                              ? FileImage(File(studentProvider.selectedUserPhotos[user['id']]!))
                              : null,
                          child: studentProvider.selectedUserPhotos.containsKey(user['id'])
                              ? null
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => studentProvider.toggleUserSelection(user['id']),
                      ),
                      onTap: () => studentProvider.toggleUserSelection(user['id']), // Tap row to select/deselect
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// **📌 Submit Button**
            studentProvider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => studentProvider.assignStudents(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Assign as Students",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
