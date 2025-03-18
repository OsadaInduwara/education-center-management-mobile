import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';

class TeacherNotificationScreen extends StatelessWidget {
  const TeacherNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your note or message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Handle message sending logic
                final message = 'Sample message'; // Add actual message logic
                await FirebaseFirestore.instance.collection('notifications').add({
                  'message': message,
                  'sender': userProvider.currentUser?.displayName,
                  'sentAt': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification sent')),
                );
              },
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
