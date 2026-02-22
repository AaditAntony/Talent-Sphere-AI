import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyApplicationsPage extends StatelessWidget {
  const CompanyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('companyId', isEqualTo: companyId)
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

              final profileImage = appData['userProfileImage'];
              final skills = List<String>.from(appData['userSkills'] ?? []);
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
                      Row(
                        children: [
                          profileImage != null && profileImage != ""
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundImage: MemoryImage(
                                    base64Decode(profileImage),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 25,
                                  child: Icon(Icons.person),
                                ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appData['userName'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  appData['userEmail'] ?? "",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text("Applied For: ${appData['jobTitle']}"),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        children: skills
                            .map((skill) => Chip(label: Text(skill)))
                            .toList(),
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

                      if (status == "pending")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('applications')
                                    .doc(appDoc.id)
                                    .update({"status": "accepted"});
                              },
                              child: const Text("Accept"),
                            ),

                            TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('applications')
                                    .doc(appDoc.id)
                                    .update({"status": "rejected"});
                              },
                              child: const Text("Reject"),
                            ),
                          ],
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
