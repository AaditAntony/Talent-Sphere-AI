import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyOverviewPage extends StatelessWidget {
  const CompanyOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('companyId', isEqualTo: companyId)
              .snapshots(),
          builder: (context, jobSnapshot) {
            if (!jobSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final totalJobs = jobSnapshot.data!.docs.length;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where('companyId', isEqualTo: companyId)
                  .snapshots(),
              builder: (context, appSnapshot) {
                if (!appSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final applications = appSnapshot.data!.docs;

                final totalApplications = applications.length;

                final pending = applications
                    .where((doc) => (doc['status'] ?? "") == "pending")
                    .length;

                final accepted = applications
                    .where((doc) => (doc['status'] ?? "") == "accepted")
                    .length;

                final efficiency = totalApplications == 0
                    ? 0
                    : ((accepted / totalApplications) * 100).toInt();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildCard(
                      "Total Jobs Posted",
                      totalJobs.toString(),
                      Icons.work_outline,
                    ),

                    const SizedBox(height: 15),

                    _buildCard(
                      "Total Applications",
                      totalApplications.toString(),
                      Icons.assignment_outlined,
                    ),

                    const SizedBox(height: 15),

                    _buildCard(
                      "Pending Applications",
                      pending.toString(),
                      Icons.hourglass_top,
                    ),

                    const SizedBox(height: 15),

                    _buildCard(
                      "Accepted Candidates",
                      accepted.toString(),
                      Icons.check_circle_outline,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "AI Hiring Efficiency",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: efficiency / 100,
                      minHeight: 10,
                      color: Colors.deepPurple,
                      backgroundColor: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "$efficiency% Efficiency Score",
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.04)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.deepPurple),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
// working