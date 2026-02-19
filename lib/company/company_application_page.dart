import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
        child: const Text("Logout"),
      ),
    );
  }
}
