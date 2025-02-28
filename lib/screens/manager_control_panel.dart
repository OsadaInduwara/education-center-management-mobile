import 'package:flutter/material.dart';

class ManagerControlPanel extends StatelessWidget {
  const ManagerControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Control Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              child: const Text('Class Management'),
              onPressed: () {
                Navigator.pushNamed(context, '/classManagement');
              },
            ),
            ElevatedButton(
              child: const Text('Register Student'),
              onPressed: () {
                Navigator.pushNamed(context, '/registerStudent');
              },
            ),
            ElevatedButton(
              child: const Text('Mark Attendance'),
              onPressed: () {
                Navigator.pushNamed(context, '/attendance');
              },
            ),
            ElevatedButton(
              child: const Text('Payment Management'),
              onPressed: () {
                // Navigator.pushNamed(context, '/payment');
              },
            ),
            ElevatedButton(
              child: const Text('Register Teacher'),
              onPressed: () {
                Navigator.pushNamed(context, '/registerTeacher');
              },
            ),
            ElevatedButton(
              child: const Text('Manage Grades'),
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
