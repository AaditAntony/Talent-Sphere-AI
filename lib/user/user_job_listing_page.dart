import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/user/user_job_detailed_page.dart';

class UserJobListingPage extends StatelessWidget {
  const UserJobListingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Jobs"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Jobs Available"),
            );
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {

              final jobDoc = jobs[index];
              final jobData =
                  jobDoc.data() as Map<String, dynamic>;
              final companyId =
                  jobData['companyId'];

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
                      companySnapshot.data!.data()
                          as Map<String, dynamic>;

                  final isApproved =
                      companyData['isApproved'] ?? false;

                  if (!isApproved) {
                    return const SizedBox();
                  }


                  final companyName =
                      jobData['companyName'] ?? "Company";

                  final companyLogo =
                  jobData['companyLogo'];

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserJobDetailPage(jobData: jobData),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            // 🔹 Company Row
                            Row(
                              children: [

                                companyLogo != null &&
                                    companyLogo != ""
                                    ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                  MemoryImage(
                                    base64Decode(
                                        companyLogo),
                                  ),
                                )
                                    : const CircleAvatar(
                                  radius: 20,
                                  child:
                                  Icon(Icons.business),
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  companyName,
                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Text(
                              jobData['title'] ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                                "Location: ${jobData['location']}"),
                            Text(
                                "Salary: ${jobData['salary']}"),
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
