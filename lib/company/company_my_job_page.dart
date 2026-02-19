import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompanyMyJobsPage extends StatelessWidget {
  const CompanyMyJobsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final companyId =
        FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
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
            child: Text(
              "No Jobs Posted Yet",
              style: TextStyle(fontSize: 16),
            ),
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

            final createdAt =
            (jobData['createdAt'] as Timestamp)
                .toDate();

            return Card(
              elevation: 5,
              margin:
              const EdgeInsets.only(bottom: 18),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // Title
                    Text(
                      jobData['title'] ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Job Type Badge
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        jobData['jobType'] ?? "",
                        style: const TextStyle(
                            color: Colors.blue),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                        "Location: ${jobData['location'] ?? ""}"),
                    Text(
                        "Salary: ${jobData['salary'] ?? ""}"),

                    const SizedBox(height: 8),

                    Text(
                      "Skills: ${jobData['requiredSkills'] ?? ""}",
                      style: const TextStyle(
                          color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Posted on: ${DateFormat('dd MMM yyyy').format(createdAt)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Align(
                      alignment:
                      Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          Colors.red,
                        ),
                        onPressed: () async {

                          await FirebaseFirestore
                              .instance
                              .collection('jobs')
                              .doc(jobDoc.id)
                              .delete();

                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Job Deleted"),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                        ),
                        label:
                        const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
