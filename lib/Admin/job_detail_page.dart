import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailPage extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobDetailPage({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  Future<void> deleteJob(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              jobData['title'] ?? "",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Location: ${jobData['location'] ?? ""}"),

            const SizedBox(height: 10),
            Text("Salary: ${jobData['salary'] ?? ""}"),

            const SizedBox(height: 10),
            Text("Required Skills: ${jobData['requiredSkills'] ?? ""}"),

            const SizedBox(height: 20),

            const Text(
              "Job Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(jobData['description'] ?? ""),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => deleteJob(context),
                child: const Text("Delete Job"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// si