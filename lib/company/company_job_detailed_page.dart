import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompanyJobDetailPage extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const CompanyJobDetailPage({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = (jobData['createdAt'] as Timestamp).toDate();

    final skills = List<String>.from(jobData['requiredSkills'] ?? []);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text(
          "Job Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Job Title Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobData['title'] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      jobData['jobType'] ?? "",
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Basic Info Card
            _buildInfoCard(
              title: "Job Information",
              children: [
                _buildRow("Location", jobData['location']),
                _buildRow("Salary", jobData['salary']),
                _buildRow(
                  "Posted On",
                  DateFormat('dd MMM yyyy, hh:mm a').format(createdAt),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 Skills Card
            _buildInfoCard(
              title: "Required Skills",
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 Description Card
            _buildInfoCard(
              title: "Job Description",
              children: [
                Text(
                  jobData['description'] ?? "",
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value ?? "",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
// working