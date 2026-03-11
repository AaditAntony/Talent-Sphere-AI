import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/user/user_job_detailed_page.dart';

class UserAIRecommendedPage extends StatelessWidget {
  const UserAIRecommendedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("AI Recommended Jobs"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(userId)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final userSkills = List<String>.from(userData['skills'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, jobSnapshot) {
              if (!jobSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final jobs = jobSnapshot.data!.docs;

              final List<Map<String, dynamic>> scoredJobs = [];

              for (var job in jobs) {
                final jobData = job.data() as Map<String, dynamic>;

                final requiredSkills = List<String>.from(
                  jobData['requiredSkills'] ?? [],
                );

                int matchCount = 0;
                List<String> matchedSkills = [];

                for (var skill in userSkills) {
                  if (requiredSkills.contains(skill)) {
                    matchCount++;
                    matchedSkills.add(skill);
                  }
                }

                double score = 0;

                if (requiredSkills.isNotEmpty) {
                  score += (matchCount / requiredSkills.length) * 80;
                }

                final createdAt = (jobData['createdAt'] as Timestamp).toDate();
                final daysOld = DateTime.now().difference(createdAt).inDays;

                if (daysOld <= 7) {
                  score += 20;
                }

                scoredJobs.add({
                  "jobDoc": job,
                  "score": score,
                  "matchedSkills": matchedSkills,
                });
              }

              scoredJobs.sort((a, b) => b['score'].compareTo(a['score']));

              final recommendedJobs = scoredJobs
                  .where((j) => j['score'] > 30)
                  .toList();

              if (recommendedJobs.isEmpty) {
                return const Center(child: Text("No AI Recommendations Yet"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recommendedJobs.length,
                itemBuilder: (context, index) {
                  final item = recommendedJobs[index];
                  final jobDoc = item['jobDoc'] as QueryDocumentSnapshot;
                  final jobData = jobDoc.data() as Map<String, dynamic>;
                  final score = item['score'] as double;
                  final matchedSkills = item['matchedSkills'] as List<String>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),

                      title: Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            color: Color(0xFF6366F1),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              jobData['title'] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.business,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jobData['companyName'] ?? "",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "AI Match: ${score.toInt()}%",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            if (matchedSkills.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: matchedSkills.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          "AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserJobDetailPage(
                              jobData: {
                                ...jobData,
                                "jobId": jobDoc.id,
                                "aiScore": score,
                                "matchedSkills": matchedSkills,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
