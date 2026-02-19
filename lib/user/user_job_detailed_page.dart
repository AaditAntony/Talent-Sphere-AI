import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserJobDetailPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const UserJobDetailPage({super.key, required this.jobData});

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
            Text(
              jobData['title'] ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text("Location: ${jobData['location']}"),
            Text("Salary: ${jobData['salary']}"),

            const SizedBox(height: 15),

            const Text(
              "Required Skills",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(jobData['requiredSkills'] ?? ""),

            const SizedBox(height: 15),

            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(jobData['description'] ?? ""),

            const SizedBox(height: 15),

            Text("Posted On: ${DateFormat('dd MMM yyyy').format(createdAt)}"),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Application logic next
              },
              child: const Text("Apply Now"),
            ),
          ],
        ),
      ),
    );
  }
}
