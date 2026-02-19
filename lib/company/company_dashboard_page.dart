import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talent_phere_ai/core/login_page.dart';
import 'package:talent_phere_ai/company/company_post_job_page.dart';


class CompanyDashboardPage extends StatelessWidget {
  const CompanyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            _dashboardCard(
              context,
              icon: Icons.add_circle,
              title: "Post Job",
              onTap: () {
                // Navigate to Post Job page done
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompanyPostJobPage(),
                  ),
                );

              },
            ),

            _dashboardCard(
              context,
              icon: Icons.work,
              title: "My Jobs",
              onTap: () {
                // Navigate to Manage Jobs page
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.people,
              title: "Applications",
              onTap: () {
                // Navigate to Applications page
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.business,
              title: "Company Profile",
              onTap: () {
                // Navigate to Profile page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
