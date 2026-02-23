import 'package:flutter/material.dart';
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
      length: 5, // change later if needed
      child: Scaffold(
        appBar: AppBar(
          title: const Text("TalentSphereAI - Admin"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Approvals"),
              Tab(text: "Companies"),
              Tab(text: "Users"),
              Tab(text: "Jobs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AdminOverviewTab(),
            CompanyApprovalTab(),
            ApprovedCompanyTab(),
            UserManagementTab(),
            JobsMonitoringTab(),
          ],
        ),
      ),
    );
  }
}
