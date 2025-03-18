import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';  // Get the current student's UID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('enrolments') // Access the 'enrollments' collection
            .doc(userUid)  // Use the student's UID to get their enrollment record
            .snapshots(), // Stream the document
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final enrollmentData = snapshot.data?.data() as Map<String, dynamic>?;
          if (enrollmentData == null || !enrollmentData.containsKey('classIds')) {
            return const Center(child: Text('You are not enrolled in any classes.'));
          }

          final classIds = List<String>.from(enrollmentData['classIds']);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .where(FieldPath.documentId, whereIn: classIds)  // Filter classes by IDs
                .snapshots(),
            builder: (context, classSnapshot) {
              if (classSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (classSnapshot.hasError) {
                return Center(child: Text('Error: ${classSnapshot.error}'));
              }

              final classes = classSnapshot.data?.docs ?? [];

              if (classes.isEmpty) {
                return const Center(child: Text('You are not enrolled in any classes.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classData = classes[index].data() as Map<String, dynamic>;
                  final className = classData['className'];
                  final classId = classes[index].id;

                  return Card(
                    color: AppColors.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 10,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.menu_book_sharp, color: Colors.white),
                      title: Text(
                        className,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassDetailsScreen(
                              classId: classId,
                              className: className,
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

class ClassDetailsScreen extends StatelessWidget {
  final String classId;
  final String className;

  const ClassDetailsScreen({Key? key, required this.classId, required this.className}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';  // Get the current student's UID

    return Scaffold(
      appBar: AppBar(
        title: Text('$className Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('classId', isEqualTo: classId) // Get records for the selected class
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final attendanceData = snapshot.data?.docs ?? [];

          if (attendanceData.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceData.length,
            itemBuilder: (context, index) {
              final record = attendanceData[index].data() as Map<String, dynamic>;
              final date = record['date'];
              final studentAttendance = record['records'] as Map<String, dynamic>;

              // Check if the current student is in the attendance records
              final studentStatus = studentAttendance[userUid];

              if (studentStatus == null) {
                // Skip if the student's attendance record for this class on this date is not found
                return const SizedBox.shrink();
              }

              return Card(
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 10,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.calendar_today, color: Colors.white),
                  title: Text('Date: $date', style: const TextStyle(color:Colors.white,fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text('Your Attendance: $studentStatus', style: const TextStyle(color:Colors.white, fontSize: 14)),
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
