import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget _buildProfileData(String label, String data) {
    return ListTile(
      title: Text(label),
      subtitle: Text(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDoc = userProvider.userDoc;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDoc == null
          ? const Center(child: Text("User data not found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundImage: (userDoc['photoUrl'] != null &&
                  (userDoc['photoUrl'] as String).isNotEmpty)
                  ? NetworkImage(userDoc['photoUrl'])
                  : const AssetImage("assets/default_profile.png")
              as ImageProvider,
            ),
            const SizedBox(height: 16),
            // Display user data
            Card(
              elevation: 2,
              child: Column(
                children: [
                  _buildProfileData("Name", userDoc['name'] ?? 'N/A'),
                  _buildProfileData(
                      "Email", userDoc['email'] ?? 'N/A'),
                  _buildProfileData(
                      "Mobile", userDoc['mobile'] ?? 'N/A'),
                  _buildProfileData(
                      "Age",
                      userDoc['age'] != null
                          ? userDoc['age'].toString()
                          : 'N/A'),
                  // Add more fields as needed.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
