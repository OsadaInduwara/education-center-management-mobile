import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget _buildProfileData(String label, String data) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        data,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDoc = userProvider.userDoc;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: AppColors.appBarText),
        ),
        backgroundColor: AppColors.appBarStart,
        iconTheme: const IconThemeData(color: AppColors.appBarIcon),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDoc == null
          ? const Center(
        child: Text(
          "User data not found.",
          style: TextStyle(color: AppColors.textPrimary),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: (userDoc['photoUrl'] != null &&
                  (userDoc['photoUrl'] as String).isNotEmpty)
                  ? NetworkImage(userDoc['photoUrl'])
                  : const AssetImage("assets/profile_placeholder.jpg")
              as ImageProvider,
            ),
            const SizedBox(height: 16),
            // User Data Card
            Card(
              elevation: 2,
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileData("Name", userDoc['name'] ?? 'N/A'),
                  _buildProfileData("Email", userDoc['email'] ?? 'N/A'),
                  _buildProfileData("Mobile", userDoc['mobile'] ?? 'N/A'),
                  _buildProfileData(
                    "Age",
                    userDoc['age'] != null
                        ? userDoc['age'].toString()
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
