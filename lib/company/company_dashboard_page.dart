import 'package:flutter/material.dart';
import 'company_post_job_page.dart';

class CompanyDashboardPage extends StatefulWidget {
  const CompanyDashboardPage({super.key});

  @override
  State<CompanyDashboardPage> createState() =>
      _CompanyDashboardPageState();
}

class _CompanyDashboardPageState
    extends State<CompanyDashboardPage> {

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CompanyOverviewPage(),
    CompanyMyJobsPage(),
    CompanyApplicationsPage(),
    CompanyProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Dashboard"),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompanyPostJobPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Overview",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "My Jobs",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Applications",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
