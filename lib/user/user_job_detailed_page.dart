import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserJobDetailPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const UserJobDetailPage({
    super.key,
    required this.jobData,
  });

  Future<void> applyForJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userId = user.uid;
    final jobId = jobData['jobId'];
    final companyId = jobData['companyId'];

    try {
      // 🔹 Check duplicate application
      final existing = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You already applied to this job"),
          ),
        );
        return;
      }

      // 🔹 Fetch user profile
      final profileDoc = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Complete your profile first"),
          ),
        );
        return;
      }

      final profileData =
          profileDoc.data() as Map<String, dynamic>;

      // 🔹 Create application document
      await FirebaseFirestore.instance
          .collection('applications')
          .add({
        "jobId": jobId,
        "jobTitle": jobData['title'],
        "companyId": companyId,
        "companyName": jobData['companyName'],

        "userId": userId,
        "userEmail": user.email,
        "userName": profileData['name'],
        "userSkills": profileData['skills'],
        "userProfileImage":
            profileData['profileImageBase64'],
        "resumeBase64":
            profileData['resumeBase64'],

        "status": "pending",
        "appliedAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application Submitted Successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt =
        (jobData['createdAt'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              jobData['title'] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Company: ${jobData['companyName']}"),

            const SizedBox(height: 10),

            Text("Location: ${jobData['location']}"),
            Text("Salary: ${jobData['salary']}"),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(jobData['description'] ?? ""),

            const SizedBox(height: 20),

            Text(
              "Posted On: ${DateFormat('dd MMM yyyy').format(createdAt)}",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    applyForJob(context),
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}