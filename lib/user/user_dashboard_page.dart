import 'package:flutter/material.dart';
import 'package:talent_phere_ai/user/user_my_applciation_page.dart';

import 'user_job_listing_page.dart';

import 'user_profile_view_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    UserJobListingPage(),
    UserMyApplicationsPage(),
    UserProfileViewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "My Applications",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
