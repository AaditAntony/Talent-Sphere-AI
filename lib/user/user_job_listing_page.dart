import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/user/user_job_detailed_page.dart';

class UserJobListingPage extends StatelessWidget {
  const UserJobListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("Available Jobs"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),

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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Company Row
                            Row(
                              children: [
                                companyLogo != null && companyLogo != ""
                                    ? CircleAvatar(
                                        radius: 24,
                                        backgroundImage: MemoryImage(
                                          base64Decode(companyLogo),
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Color(0xFFEEF2FF),
                                        child: Icon(
                                          Icons.business,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    companyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),

                                if (jobData['jobType'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      jobData['jobType'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6366F1),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            /// Job Title
                            Text(
                              jobData['title'] ?? "",
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Location + Salary
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  jobData['location'] ?? "",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),

                                const SizedBox(width: 18),

                                const Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  jobData['salary'] ?? "",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            /// Skills
                            if (skills.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills
                                    .take(4)
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),

                            const SizedBox(height: 14),

                            /// Description preview
                            if (jobData['description'] != null)
                              Text(
                                jobData['description'].toString().length > 80
                                    ? "${jobData['description'].toString().substring(0, 80)}..."
                                    : jobData['description'],
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
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
//