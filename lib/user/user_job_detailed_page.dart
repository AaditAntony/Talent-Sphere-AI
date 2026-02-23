import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserJobDetailPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const UserJobDetailPage({super.key, required this.jobData});

  Future<void> applyForJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final jobId = jobData['jobId'];
    final companyId = jobData['companyId'];

    try {
      // 🔹 Prevent duplicate applications
      final existing = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You already applied to this job")),
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
          const SnackBar(content: Text("Complete your profile first")),
        );
        return;
      }

      final profileData = profileDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('applications').add({
        "jobId": jobId,
        "jobTitle": jobData['title'],
        "companyId": companyId,
        "companyName": jobData['companyName'],
        "userId": userId,
        "userEmail": user.email,
        "userName": profileData['name'],
        "userSkills": profileData['skills'],
        "userProfileImage": profileData['profileImage'],
        "resumeBase64": profileData['resume'],
        "status": "pending",
        "appliedAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application Submitted Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = (jobData['createdAt'] as Timestamp).toDate();

    final double aiScore = jobData['aiScore'] ?? 0;

    final List<String> matchedSkills = List<String>.from(
      jobData['matchedSkills'] ?? [],
    );

    final List<String> requiredSkills = List<String>.from(
      jobData['requiredSkills'] ?? [],
    );

    final List<String> missingSkills = requiredSkills
        .where((skill) => !matchedSkills.contains(skill))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Job Title
            Text(
              jobData['title'] ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              jobData['companyName'] ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔥 AI Analysis Box
            if (aiScore > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          "AI Recommendation Analysis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Match Confidence: ${aiScore.toInt()}%",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (matchedSkills.isNotEmpty)
                      Text(
                        "Matching Skills: ${matchedSkills.join(', ')}",
                        style: const TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 8),

                    if (missingSkills.isNotEmpty)
                      Text(
                        "Skills To Improve: ${missingSkills.join(', ')}",
                        style: const TextStyle(color: Colors.orange),
                      ),

                    const SizedBox(height: 10),

                    Text(
                      generateAIMessage(aiScore),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],

            // 🔥 Location & Salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📍 ${jobData['location']}"),
                Text("💰 ${jobData['salary']}"),
              ],
            ),

            const SizedBox(height: 25),

            // 🔥 Required Skills
            const Text(
              "Required Skills",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requiredSkills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 25),

            // 🔥 Description
            const Text(
              "Job Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              jobData['description'] ?? "",
              style: const TextStyle(height: 1.5),
            ),

            const SizedBox(height: 20),

            Text(
              "Posted On: ${DateFormat('dd MMM yyyy').format(createdAt)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => applyForJob(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Apply Now", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generateAIMessage(double score) {
    if (score >= 80) {
      return "Our AI strongly recommends this role based on your profile.";
    } else if (score >= 60) {
      return "You have strong alignment with this opportunity.";
    } else if (score >= 40) {
      return "Moderate skill alignment detected. Upskilling could improve compatibility.";
    } else {
      return "Limited alignment found. Consider building relevant skills.";
    }
  }
}
