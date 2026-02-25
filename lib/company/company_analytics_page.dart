import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

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

                // ================= METRIC CARDS =================
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _metricCard("Total Jobs", data['totalJobs']),
                    _metricCard("Applications", data['totalApplications']),
                    _metricCard("Accepted", data['accepted']),
                    _metricCard("Pending", data['pending']),
                    _metricCard("Rejected", data['rejected']),
                    _metricCard(
                      "Acceptance Rate",
                      "${data['acceptanceRate']}%",
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ================= AI INSIGHT =================
                const Text(
                  "AI Hiring Insight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Text(
                    _generateInsight(data),
                    style: const TextStyle(height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),

                // ================= ANALYTICS OVERVIEW =================
                const Text(
                  "Analytics Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAR CHART
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Applications per Job",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(height: 220, child: _buildBarChart(data)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 25),

                      // PIE CHART
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status Distribution",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(height: 180, child: _buildPieChart(data)),
                            const SizedBox(height: 15),
                            _buildLegend(),
                          ],
                        ),
                      ),
                    ],
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

    for (var doc in applicationsSnapshot.docs) {
      final data = doc.data();
      final status = data['status'];

      if (status == "accepted") accepted++;
      if (status == "rejected") rejected++;
      if (status == "pending") pending++;

      final jobTitle = data['jobTitle'] ?? "Unknown";
      jobApplicationCount[jobTitle] = (jobApplicationCount[jobTitle] ?? 0) + 1;
    }

    double acceptanceRate = 0;
    if (totalApplications > 0) {
      acceptanceRate = (accepted / totalApplications) * 100;
    }

    return {
      "totalJobs": totalJobs,
      "totalApplications": totalApplications,
      "accepted": accepted,
      "rejected": rejected,
      "pending": pending,
      "acceptanceRate": acceptanceRate.toInt(),
      "jobApplicationCount": jobApplicationCount,
    };
  }

  // ================= METRIC CARD =================

  Widget _metricCard(String title, dynamic value) {
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
            value.toString(),
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

  // ================= BAR CHART =================

  Widget _buildBarChart(Map<String, dynamic> data) {
    final jobMap = Map<String, int>.from(data['jobApplicationCount']);

    if (jobMap.isEmpty) {
      return const Center(child: Text("No data"));
    }

    int index = 0;
    final entries = jobMap.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) {
                  return const SizedBox();
                }
                return Text(
                  entries[value.toInt()].key,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        barGroups: entries.map((entry) {
          final group = BarChartGroupData(
            x: index++,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.deepPurple,
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
          return group;
        }).toList(),
      ),
    );
  }

  // ================= PIE CHART =================

  Widget _buildPieChart(Map<String, dynamic> data) {
    final accepted = data['accepted'];
    final rejected = data['rejected'];
    final pending = data['pending'];

    if (accepted + rejected + pending == 0) {
      return const Center(child: Text("No applications"));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: accepted.toDouble(),
            color: Colors.green,
            title: "",
          ),
          PieChartSectionData(
            value: rejected.toDouble(),
            color: Colors.red,
            title: "",
          ),
          PieChartSectionData(
            value: pending.toDouble(),
            color: Colors.orange,
            title: "",
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LegendItem(color: Colors.green, text: "Accepted"),
        SizedBox(height: 6),
        _LegendItem(color: Colors.red, text: "Rejected"),
        SizedBox(height: 6),
        _LegendItem(color: Colors.orange, text: "Pending"),
      ],
    );
  }

  String _generateInsight(Map<String, dynamic> data) {
    if (data['totalApplications'] == 0) {
      return "No applications received yet. Promote your job postings to increase visibility.";
    }

    if (data['acceptanceRate'] > 60) {
      return "Strong hiring efficiency detected. Continue maintaining quick review cycles.";
    }

    if (data['pending'] > data['accepted']) {
      return "High pending applications detected. Faster review could improve hiring performance.";
    }

    return "Hiring performance is moderate. Optimizing job descriptions may improve candidate alignment.";
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
