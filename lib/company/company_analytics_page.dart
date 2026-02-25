import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyAnalyticsPage extends StatelessWidget {
  const CompanyAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder(
        future: _loadAnalytics(companyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hiring Analytics",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 🔥 Metrics Grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _metricCard("Total Jobs", data['totalJobs'].toString()),
                    _metricCard(
                      "Total Applications",
                      data['totalApplications'].toString(),
                    ),
                    _metricCard("Accepted", data['accepted'].toString()),
                    _metricCard("Pending", data['pending'].toString()),
                    _metricCard("Rejected", data['rejected'].toString()),
                    _metricCard(
                      "Acceptance Rate",
                      "${data['acceptanceRate']}%",
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "AI Hiring Insight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Text(
                    _generateInsight(data),
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= LOGIC =================

  Future<Map<String, dynamic>> _loadAnalytics(String companyId) async {
    final jobsSnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .get();

    final applicationsSnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .get();

    final totalJobs = jobsSnapshot.docs.length;
    final totalApplications = applicationsSnapshot.docs.length;

    int accepted = 0;
    int rejected = 0;
    int pending = 0;

    Map<String, int> jobApplicationCount = {};
    Map<String, int> skillFrequency = {};

    for (var doc in applicationsSnapshot.docs) {
      final data = doc.data();
      final status = data['status'];

      if (status == "accepted") accepted++;
      if (status == "rejected") rejected++;
      if (status == "pending") pending++;

      final jobTitle = data['jobTitle'] ?? "Unknown";
      jobApplicationCount[jobTitle] = (jobApplicationCount[jobTitle] ?? 0) + 1;

      final skills = List<String>.from(data['userSkills'] ?? []);
      for (var skill in skills) {
        skillFrequency[skill] = (skillFrequency[skill] ?? 0) + 1;
      }
    }

    double acceptanceRate = 0;
    if (totalApplications > 0) {
      acceptanceRate = (accepted / totalApplications) * 100;
    }

    String mostAppliedJob = "N/A";
    if (jobApplicationCount.isNotEmpty) {
      mostAppliedJob = jobApplicationCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    String topSkill = "N/A";
    if (skillFrequency.isNotEmpty) {
      topSkill = skillFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      "totalJobs": totalJobs,
      "totalApplications": totalApplications,
      "accepted": accepted,
      "rejected": rejected,
      "pending": pending,
      "acceptanceRate": acceptanceRate.toInt(),
      "mostAppliedJob": mostAppliedJob,
      "topSkill": topSkill,
    };
  }

  // ================= UI HELPERS =================

  Widget _metricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _generateInsight(Map<String, dynamic> data) {
    if (data['totalApplications'] == 0) {
      return "No applications received yet. Promote your job postings to increase visibility.";
    }

    if (data['acceptanceRate'] > 60) {
      return "Strong hiring efficiency detected. Most candidates apply for ${data['mostAppliedJob']}. Top skill in demand: ${data['topSkill']}.";
    }

    if (data['pending'] > data['accepted']) {
      return "You have many pending applications. Faster review can improve hiring conversion rate.";
    }

    return "Your hiring activity is moderate. Consider optimizing job descriptions to attract better-matched candidates.";
  }
}
