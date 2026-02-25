import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talent_phere_ai/Admin/admin_login.dart';
import 'package:talent_phere_ai/Admin/admiin_overview_tab.dart';
import 'package:talent_phere_ai/Admin/approved_company_tabs.dart';
import 'package:talent_phere_ai/Admin/company_approval_tab.dart';
import 'package:talent_phere_ai/Admin/job_monitoring_tab.dart';
import 'package:talent_phere_ai/Admin/user_management_tab.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),

        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          centerTitle: false,

          title: const Text(
            "TalentSphereAI Admin",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),

          actions: [
            IconButton(
              tooltip: "Sign Out",
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(width: 16),
          ],

          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Approvals"),
              Tab(text: "Companies"),
              Tab(text: "Users"),
              Tab(text: "Jobs"),
            ],
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(24),
          child: TabBarView(
            children: [
              _contentWrapper(const AdminOverviewTab()),
              _contentWrapper(const CompanyApprovalTab()),
              _contentWrapper(const ApprovedCompanyTab()),
              _contentWrapper(const UserManagementTab()),
              _contentWrapper(const JobsMonitoringTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentWrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}
