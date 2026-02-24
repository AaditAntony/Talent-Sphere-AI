import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_detailed_page.dart';

class CompanyApplicationsPage extends StatelessWidget {
  const CompanyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
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
              return const Center(
                child: Text(
                  "No Applications Yet",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final appDoc = applications[index];
                final appData = appDoc.data() as Map<String, dynamic>;

                final skills = List<String>.from(appData['userSkills'] ?? []);

                final status = appData['status'] ?? "pending";

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Top Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appData['userProfileImage'] != null
                              ? CircleAvatar(
                                  radius: 28,
                                  backgroundImage: MemoryImage(
                                    base64Decode(appData['userProfileImage']),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 28,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appData['userEmail'] ?? "",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Applied For: ${appData['jobTitle']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _buildStatusBadge(status),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // 🔥 Skills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills
                            .map(
                              (skill) => Chip(
                                label: Text(skill),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 18),

                      // 🔹 View Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicantDetailPage(
                                  applicationId: appDoc.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.deepPurple,
                          ),
                          label: const Text(
                            "View Profile",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      // 🔹 Accept / Reject if pending
                      if (status == "pending") ...[
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('applications')
                                      .doc(appDoc.id)
                                      .update({"status": "accepted"});
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Accept"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('applications')
                                      .doc(appDoc.id)
                                      .update({"status": "rejected"});
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    if (status == "accepted") {
      color = Colors.green;
    } else if (status == "rejected") {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
