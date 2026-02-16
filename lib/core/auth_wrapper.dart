import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/company/company_dashboard_page.dart';
import 'package:talent_phere_ai/company/company_profile_setup.dart';
import 'package:talent_phere_ai/company/waiting_approval_screen.dart';

//import '../company/company_dashboard_page.dart';
//import '../user/user_dashboard_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 🔄 Loading state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!authSnapshot.hasData) {
          return const LoginPage();
        }

        final uid = authSnapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;

            final role = data['role'];
            final isApproved = data['isApproved'] ?? false;
            final isProfileComplete = data['isProfileComplete'] ?? false;

            // 🟢 USER FLOW
            if (role == "user") {
              //return const UserDashboardPage();
            }

            // 🟣 COMPANY FLOW
            if (role == "company") {
              if (!isProfileComplete) {
                return const CompanyProfileSetupPage();
              }

              if (isProfileComplete && !isApproved) {
                return const WaitingApprovalPage();
              }

              if (isApproved) {
                return const CompanyDashboardPage();
              }
            }

            // 🔴 ADMIN ON MOBILE (Not Allowed)
            if (role == "admin") {
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }

            // Default fallback
            return const LoginPage();
          },
        );
      },
    );
  }
}
