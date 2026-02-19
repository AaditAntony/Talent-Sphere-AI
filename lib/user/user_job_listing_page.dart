import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
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
                              "Location: ${jobData['location'] ?? ""}"),
                          Text(
                              "Salary: ${jobData['salary'] ?? ""}"),
                        ],
                      ),
                      trailing: const Icon(
                          Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) =>
                        //         UserJobDetailPage(
                        //       jobData: jobData,
                        //     ),
                        //   ),
                        // );
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
