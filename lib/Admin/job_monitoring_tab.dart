import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobsMonitoringTab extends StatelessWidget {
  const JobsMonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(child: Text("No Jobs Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {

            final data = jobs[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.work),
                ),
                title: Text(
                  data['title'] ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Location: ${data['location'] ?? ""}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailPage(
                        jobId: jobs[index].id,
                        jobData: data.data(),
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
  }
}
