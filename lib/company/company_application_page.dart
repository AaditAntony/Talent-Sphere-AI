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

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: appData['userProfileImage'] != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64Decode(appData['userProfileImage']),
                          ),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(appData['userName'] ?? ""),
                  subtitle: Text(appData['jobTitle'] ?? ""),
                  trailing: Text(appData['status'] ?? "pending"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicantDetailPage(
                          applicationId: appDoc.id,
                          applicationData: appData,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// resume fixed