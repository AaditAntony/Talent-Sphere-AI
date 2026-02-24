import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/company/resumer_view_page.dart';

class ApplicantDetailPage extends StatelessWidget {
  final String applicationId;
  final Map<String, dynamic> applicationData;

  const ApplicantDetailPage({
    super.key,
    required this.applicationId,
    required this.applicationData,
  });

  @override
  Widget build(BuildContext context) {
    final skills = List<String>.from(applicationData['userSkills'] ?? []);

    final resume = applicationData['resumeBase64'];

    return Scaffold(
      appBar: AppBar(title: const Text("Applicant")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              applicationData['userName'] ?? "",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Email: ${applicationData['userEmail']}"),

            const SizedBox(height: 20),

            const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold)),

            Wrap(
              spacing: 8,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),

            const SizedBox(height: 30),

            // 🔥 Resume Button
            if (resume != null && resume != "")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResumeViewerPage(base64Pdf: resume),
                      ),
                    );
                  },
                  child: const Text("View Resume"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
