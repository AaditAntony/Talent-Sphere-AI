import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobDetailPage({super.key, required this.jobId, required this.jobData});

  Future<void> deleteJob(BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = (jobData['createdAt'] as Timestamp?)?.toDate();

    final skills = List<String>.from(jobData['requiredSkills'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text("Job Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: _cardDecoration(),
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

                  Text(
                    jobData['companyName'] ?? "",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _metaChip(
                        icon: Icons.location_on_outlined,
                        text: jobData['location'] ?? "",
                        color: const Color(0xFF2563EB),
                      ),
                      _metaChip(
                        icon: Icons.attach_money,
                        text: jobData['salary'] ?? "",
                        color: const Color(0xFF16A34A),
                      ),
                      _metaChip(
                        icon: Icons.work_outline,
                        text: jobData['jobType'] ?? "",
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),

                  if (createdAt != null) ...[
                    const SizedBox(height: 15),
                    Text(
                      "Posted on ${DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Skills Card
            if (skills.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(25),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Required Skills",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skills
                          .map(
                            (skill) => Chip(
                              label: Text(skill),
                              backgroundColor: const Color(
                                0xFF2563EB,
                              ).withOpacity(0.08),
                              labelStyle: const TextStyle(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // 🔹 Description Card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Description",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    jobData['description'] ?? "",
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  "Delete Job",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => deleteJob(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          blurRadius: 15,
          offset: const Offset(0, 6),
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
