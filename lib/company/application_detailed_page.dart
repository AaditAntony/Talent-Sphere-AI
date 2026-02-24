import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/company/resumer_view_page.dart';

class ApplicantDetailPage extends StatelessWidget {
  final String applicationId;

  const ApplicantDetailPage({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applicant Details")),
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('applications')
            .doc(applicationId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Application Not Found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final skills = List<String>.from(data['userSkills'] ?? []);

          final resume = data['resumeBase64'];

          final status = data['status'] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 Profile Section
                Row(
                  children: [
                    data['userProfileImage'] != null
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: MemoryImage(
                              base64Decode(data['userProfileImage']),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 35,
                            child: Icon(Icons.person),
                          ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['userName'] ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['userEmail'] ?? "",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔥 Status Badge
                _buildStatusBadge(status),

                const SizedBox(height: 25),

                const Text(
                  "Skills",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((skill) => Chip(label: Text(skill)))
                      .toList(),
                ),

                const SizedBox(height: 30),

                // 🔥 Resume Button
                if (resume != null && resume != "")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumeViewerPage(base64Pdf: resume),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text(
                        "View Resume",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    if (status == "accepted") {
      color = Colors.green;
    } else if (status == "rejected") {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
