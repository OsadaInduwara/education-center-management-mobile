import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ManagerControlPanel extends StatelessWidget {
  const ManagerControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manager Control Panel',
          style: TextStyle(color: AppColors.appBarText),
        ),
        backgroundColor: AppColors.appBarStart,
        iconTheme: const IconThemeData(color: AppColors.appBarIcon),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Class Management',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/classManagement');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Assign Student',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/assignStudent');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mark Attendance',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/attendance');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Payment Management',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                // Navigator.pushNamed(context, '/payment');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Assign Teacher',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/assignTeacher');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Manage Grades',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/managegrade');
              },
            ),
          ],
        ),
      ),
    );
  }
}
