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
      final existing = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("You already applied")));
        return;
      }

      final profileDoc = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Complete profile first")));
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
        "userProfileImage": profileData['profileImageBase64'],
        "resumeBase64": profileData['resumeBase64'],
        "status": "pending",
        "appliedAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Application Submitted")));
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Job Details"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Job Title
            Text(
              jobData['title'] ?? "",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              jobData['companyName'] ?? "",
              style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            /// AI Analysis
            if (aiScore > 0) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
                        SizedBox(width: 8),
                        Text(
                          "AI Recommendation",
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

                    const SizedBox(height: 6),

                    if (missingSkills.isNotEmpty)
                      Text(
                        "Skills To Improve: ${missingSkills.join(', ')}",
                        style: const TextStyle(color: Colors.orange),
                      ),

                    const SizedBox(height: 10),

                    Text(
                      generateAIMessage(aiScore),
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],

            /// Job Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(jobData['location'] ?? ""),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.grey,
                      ),
                      Text(jobData['salary'] ?? ""),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Skills
            const Text(
              "Required Skills",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requiredSkills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(skill),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 25),

            /// Description
            const Text(
              "Job Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 10),

            Text(
              jobData['description'] ?? "",
              style: const TextStyle(height: 1.6, color: Color(0xFF334155)),
            ),

            const SizedBox(height: 20),

            Text(
              "Posted On: ${DateFormat('dd MMM yyyy').format(createdAt)}",
              style: const TextStyle(color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 35),

            /// Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => applyForJob(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Apply Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
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
