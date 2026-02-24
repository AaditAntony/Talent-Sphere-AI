import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/Admin/admin_dashboard.dart';
import 'package:talent_phere_ai/company/company_dashboard_page.dart';
import 'package:talent_phere_ai/company/company_profile_setup.dart';
import 'package:talent_phere_ai/company/waiting_approval_screen.dart';
import 'package:talent_phere_ai/user/user_dashboard_page.dart';
import 'package:talent_phere_ai/user/user_profile_setup_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 Not logged in
        if (!authSnapshot.hasData) {
          return const LoginPage();
        }

        final uid = authSnapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const LoginPage();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;

            final role = userData['role'];
            final isProfileComplete = userData['isProfileComplete'] ?? false;
            final isApproved = userData['isApproved'] ?? false;

            // 🔴 ADMIN
            if (role == "admin") {
              return const AdminDashboardPage();
            }

            // 🔵 COMPANY FLOW (FIXED)
            if (role == "company") {
              // Step 1 → Profile not completed
              if (!isProfileComplete) {
                return const CompanyProfileSetupPage();
              }

              // Step 2 → Profile completed but not approved
              if (!isApproved) {
                return const WaitingApprovalPage();
              }

              // Step 3 → Approved
              return const CompanyDashboardPage();
            }

            // 🟢 USER FLOW
            if (role == "user") {
              if (!isProfileComplete) {
                return const UserProfileSetupPage();
              }

              return const UserDashboardPage();
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}
