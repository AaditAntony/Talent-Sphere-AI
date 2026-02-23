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

    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              jobData['title'] ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Job Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                jobData['jobType'] ?? "",
                style: const TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 20),

            Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(jobData['location'] ?? ""),

            const SizedBox(height: 15),

            Text("Salary", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(jobData['salary'] ?? ""),

            const SizedBox(height: 15),

            Text(
              "Required Skills",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              children: List<String>.from(
                jobData['requiredSkills'] ?? [],
              ).map((skill) => Chip(label: Text(skill))).toList(),
            ),

            const SizedBox(height: 15),

            Text(
              "Job Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(jobData['description'] ?? ""),

            const SizedBox(height: 20),

            Text("Posted On", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)),
          ],
        ),
      ),
    );
  }
}
// working on job details issue solved in the requeired skill