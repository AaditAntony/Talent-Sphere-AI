import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMyApplicationsPage extends StatelessWidget {
  const UserMyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: userId)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = snapshot.data!.docs;

          if (applications.isEmpty) {
            return const Center(child: Text("No Applications Yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final appDoc = applications[index];
              final appData = appDoc.data() as Map<String, dynamic>;

              final status = appData['status'] ?? "pending";

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appData['jobTitle'] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Company: ${appData['companyName']}",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "accepted"
                              ? Colors.green
                              : status == "rejected"
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
