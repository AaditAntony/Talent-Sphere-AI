import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'admin_dashboard_page.dart';
// import 'company_dashboard_page.dart';
// import 'user_dashboard_page.dart';
// import 'waiting_approval_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data!;
            final role = userData['role'];
            final isApproved = userData['isApproved'] ?? false;

            // ===== WEB PLATFORM =====
            if (kIsWeb) {
              if (role == "admin" && isApproved == true) {
                // return const AdminDashboardPage();
              } else {
                FirebaseAuth.instance.signOut();
                return const LoginPage();
              }
            }

            // ===== MOBILE PLATFORM =====
            // if (!kIsWeb) {

            //   if (role == "user") {
            //     return const UserDashboardPage();
            //   }

            //   if (role == "company") {
            //     if (isApproved == true) {
            //       return const CompanyDashboardPage();
            //     } else {
            //       return const WaitingApprovalPage();
            //     }
            //   }

            //   if (role == "admin") {
            //     FirebaseAuth.instance.signOut();
            //     return const LoginPage();
            //   }
            // }

            return const LoginPage();
          },
        );
      },
    );
  }
}
