import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/Admin/admin_dashboard.dart';

import '../core/login_page.dart';
import '../user/user_job_listing_page.dart';
import '../user/user_profile_setup_page.dart';
import '../company/company_dashboard_page.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 🔹 Not logged in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, userSnapshot) {

            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final userData =
            userSnapshot.data!.data()
            as Map<String, dynamic>;

            final role = userData['role'];
            final isProfileComplete =
                userData['isProfileComplete'] ?? false;
            final isApproved =
                userData['isApproved'] ?? false;

            // 🔴 ADMIN
            if (role == "admin") {
              return const AdminDashboardPage();
            }

            // 🔵 COMPANY
            if (role == "company") {

              if (!isApproved) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                        "Waiting for approval"),
                  ),
                );
              }

              return const CompanyDashboardPage();
            }

            // 🟢 USER
            if (role == "user") {

              if (!isProfileComplete) {
                return const UserProfileSetupPage();
              }

              return const UserJobListingPage();
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}