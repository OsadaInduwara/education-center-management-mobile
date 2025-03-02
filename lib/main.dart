import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:student_book/providers/class_provider.dart';
import 'package:student_book/screens/main/class_detail_screen.dart';
import 'package:student_book/screens/main/home_screen.dart';
import 'package:student_book/screens/main/manager_control_panel.dart';
import 'package:student_book/screens/manager/attendance_screen.dart';
import 'package:student_book/screens/main/profile_screen.dart';
import 'package:student_book/screens/manager/class_management_screen.dart';
import 'package:student_book/screens/manager/manage_grades_screens.dart';
import 'package:student_book/screens/manager/register_student_screen.dart';
import 'package:student_book/screens/manager/register_teacher_screen.dart';
import 'package:student_book/providers/user_provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<ClassProvider>(
          create: (_) => ClassProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'My Institute App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/managerPanel': (context) => const ManagerControlPanel(),
          '/classManagement': (context) => const ClassManagementScreen(),
          '/registerStudent': (context) => const RegisterStudentScreen(),
          '/registerTeacher': (context) => const RegisterTeacherScreen(),
          '/attendance': (context) => const MarkAttendanceScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/managegrade': (context) => const ManageGradesScreen(),
          '/classdetail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ClassDetailScreen(classData: args);
          }


        },
      ),
    );
  }
}
