import 'package:flutter/material.dart';

class CompanyAnalyticsPage extends StatelessWidget {
  const CompanyAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hiring Analytics"),
      ),
      body: const Center(
        child: Text(
          "Analytics Coming Soon...",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}