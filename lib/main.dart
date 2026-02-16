import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:talent_phere_ai/Admin/admin_login.dart';
import 'package:talent_phere_ai/core/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TalentSphereAI',

      home: kIsWeb
          ? const AdminLoginPage() // 🌐 Web → Admin
          : const AuthWrapper(), // 📱 Mobile → User/Company
    );
  }
}
