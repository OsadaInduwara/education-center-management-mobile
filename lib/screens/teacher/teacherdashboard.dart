import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart'; // Update the import according to your project structure

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final teacherId = user?.uid ?? ''; // Teacher's UID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching grades from the classes collection based on the teacher's ID
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('classTeacherId', isEqualTo: teacherId) // Filter classes by teacherId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data?.docs ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('You are not assigned to any classes.'));
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index].data() as Map<String, dynamic>;
              final gradeId = classData['gradeId']; // Get gradeId from the class

              // Fetch grade name using the gradeId
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('grades').doc(gradeId).get(),
                builder: (context, gradeSnapshot) {
                  if (gradeSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (gradeSnapshot.hasError) {
                    return Center(child: Text('Error: ${gradeSnapshot.error}'));
                  }

                  final gradeData = gradeSnapshot.data?.data() as Map<String, dynamic>;
                  final gradeName = gradeData?['gradeName'] ?? 'Unknown Grade';

                  return Card(
                    color: AppColors.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 10,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.menu_book_sharp, color: Colors.white),
                      title: Text(gradeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        // Navigate to the class details screen for the selected class
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassListScreen(
                              gradeId: gradeId,
                              gradeName: gradeName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ClassListScreen extends StatelessWidget {
  final String gradeId;
  final String gradeName;

  const ClassListScreen({Key? key, required this.gradeId, required this.gradeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes for Grade: $gradeName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching all classes for the selected grade
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('gradeId', isEqualTo: gradeId) // Filter classes by gradeId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data?.docs ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('No classes found.'));
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index].data() as Map<String, dynamic>;
              final classId = classData['classId'];
              final className = classData['className'];

              return Card(
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 10,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.menu_book_sharp, color: Colors.white),
                  title: Text(className, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () {
                    // Navigate to the class details screen for the selected class
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailsScreen(
                          classId: classId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClassDetailsScreen extends StatelessWidget {
  final String classId;

  const ClassDetailsScreen({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Attendance Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching all attendance records for the class
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('classId', isEqualTo: classId) // Filter by classId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final attendanceRecords = snapshot.data?.docs ?? [];

          if (attendanceRecords.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index].data() as Map<String, dynamic>;
              final date = record['date'];
              final studentsAttendance = record['records'] as Map<String, dynamic>;

              return Card(
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 10,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.calendar_today, color: Colors.white),
                  title: Text('Date: $date', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: studentsAttendance.entries.map((entry) {
                      return Text('${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white, fontSize: 14));
                    }).toList(),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
