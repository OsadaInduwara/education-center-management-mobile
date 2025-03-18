import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grade_provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import 'grade_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    // Prevents logout issue on app restart
    if (user == null && !userProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(  
              children: [
                // Background image
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/appbar_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.appBarStart.withOpacity(0.5),
                        AppColors.appBarEnd.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/profile_placeholder.jpg'),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome,',
                                    style: TextStyle(fontSize: 14, color: AppColors.appBarText),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.appBarText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person, color: AppColors.appBarIcon),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: AppColors.appBarIcon),
                                onPressed: () async {
                                  await userProvider.signOut();
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: _buildContent(userProvider.role),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/subscrition'); // Replace '/newPage' with the actual route
          },
        ),

      ),
    );
  }

  Widget _buildContent(String? role) {
    return Column(
      children: [
        if (role == 'manager')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/managerPanel');
              },
              child: const Text(
                'Go to Manager Control Panel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        if (role == 'student')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/studentdashboard');
              },
              child: const Text(
                'Student Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        if (role == 'teacher')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/teacherdashboard');
              },
              child: const Text(
                'Teacher Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

        const SizedBox(height: 10),
        Expanded(child: _buildGradeList()),
      ],
    );
  }

  Widget _buildGradeList() {
    return Consumer<GradesProvider>(
      builder: (context, gradesProvider, _) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: gradesProvider.gradesStream, // ✅ Firestore real-time updates
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            final grades = snapshot.data ?? [];

            if (grades.isEmpty) {
              return const Center(
                child: Text(
                  'No grades found.',
                  style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                ),
              );
            }


            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return Card(
                  color: AppColors.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 10,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(Icons.menu_book_sharp, color: Colors.white),
                    ),
                    title: Text(
                      grade['gradeName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradeDetailScreen(
                            gradeId: grade['gradeId'],
                            gradeName: grade['gradeName'],

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
    );
  }
}
