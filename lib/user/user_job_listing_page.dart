import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/user/user_job_detailed_page.dart';

class UserJobListingPage extends StatelessWidget {
  const UserJobListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Jobs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Jobs Available"));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobDoc = jobs[index];
              final jobData = jobDoc.data() as Map<String, dynamic>;

              final companyId = jobData['companyId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(companyId)
                    .get(),
                builder: (context, companySnapshot) {
                  if (!companySnapshot.hasData ||
                      !companySnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final companyData =
                      companySnapshot.data!.data() as Map<String, dynamic>;

                  final isApproved = companyData['isApproved'] ?? false;

                  if (!isApproved) {
                    return const SizedBox();
                  }

                  final companyName = jobData['companyName'] ?? "Company";

                  final companyLogo = jobData['companyLogo'];

                  final List<String> skills = List<String>.from(
                    jobData['requiredSkills'] ?? [],
                  );

                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserJobDetailPage(
                              jobData: {...jobData, "jobId": jobDoc.id},
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Company Row
                            Row(
                              children: [
                                companyLogo != null && companyLogo != ""
                                    ? CircleAvatar(
                                        radius: 22,
                                        backgroundImage: MemoryImage(
                                          base64Decode(companyLogo),
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 22,
                                        child: Icon(Icons.business),
                                      ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    companyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                // Job Type Badge
                                if (jobData['jobType'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      jobData['jobType'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 🔹 Job Title
                            Text(
                              jobData['title'] ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 🔹 Location & Salary
                            Row(
                              children: [
                                Text("📍 ${jobData['location']}"),
                                const SizedBox(width: 15),
                                Text("💰 ${jobData['salary']}"),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 🔹 Skills Chips
                            if (skills.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: skills
                                    .take(4) // show only 4
                                    .map(
                                      (skill) => Chip(
                                        label: Text(skill),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                    )
                                    .toList(),
                              ),

                            const SizedBox(height: 12),

                            // 🔹 Short Description Preview
                            if (jobData['description'] != null)
                              Text(
                                jobData['description'].toString().length > 80
                                    ? "${jobData['description'].toString().substring(0, 80)}..."
                                    : jobData['description'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
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
