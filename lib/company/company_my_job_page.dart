import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Type: ${jobData['jobType'] ?? ""}"),
                    Text(
                        "Location: ${jobData['location'] ?? ""}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {

                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(jobDoc.id)
                        .delete();

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                          content:
                          Text("Job Deleted")),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
