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
      appBar: AppBar(title: const Text("AI Recommended Jobs")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(userId)
            .get(),
        builder: (context, userSnapshot) {

          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              userSnapshot.data!.data() as Map<String, dynamic>;

          final userSkills =
              List<String>.from(userData['skills'] ?? []);

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

                final jobData =
                    job.data() as Map<String, dynamic>;

                final requiredSkills =
                    List<String>.from(
                        jobData['requiredSkills'] ?? []);

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
                  score +=
                      (matchCount / requiredSkills.length) * 80;
                }

                // Recent job bonus
                final createdAt =
                    (jobData['createdAt'] as Timestamp)
                        .toDate();
                final daysOld =
                    DateTime.now().difference(createdAt).inDays;

                if (daysOld <= 7) {
                  score += 20;
                }

                scoredJobs.add({
                  "jobDoc": job,
                  "score": score,
                  "matchedSkills": matchedSkills,
                });
              }

              scoredJobs.sort((a, b) =>
                  b['score'].compareTo(a['score']));

              final recommendedJobs = scoredJobs
                  .where((j) => j['score'] > 30)
                  .toList();

              if (recommendedJobs.isEmpty) {
                return const Center(
                  child: Text("No AI Recommendations Yet"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recommendedJobs.length,
                itemBuilder: (context, index) {

                  final item = recommendedJobs[index];
                  final jobDoc =
                      item['jobDoc'] as QueryDocumentSnapshot;
                  final jobData =
                      jobDoc.data()
                          as Map<String, dynamic>;
                  final score =
                      item['score'] as double;
                  final matchedSkills =
                      item['matchedSkills'] as List<String>;

                  return Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      title: Text(
                        jobData['title'] ?? "",
                        style: const TextStyle(
                            fontWeight:
                                FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Company: ${jobData['companyName']}"),
                          const SizedBox(height: 5),
                          Text(
                            "AI Match: ${score.toInt()}%",
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                          if (matchedSkills.isNotEmpty)
                            Text(
                              "Matching Skills: ${matchedSkills.join(', ')}",
                              style: const TextStyle(
                                  color: Colors.green),
                            ),
                        ],
                      ),
                      trailing: Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "AI",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserJobDetailPage(
                              jobData: {
                                ...jobData,
                                "jobId":
                                    jobDoc.id,
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