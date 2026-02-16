import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/Admin/company_detail_page.dart';

class CompanyApprovalTab extends StatelessWidget {
  const CompanyApprovalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final companies = snapshot.data!.docs;

        if (companies.isEmpty) {
          return const Center(child: Text("No Companies Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: companies.length,
          itemBuilder: (context, index) {

            final companyDoc = companies[index];
            final companyId = companyDoc.id;
            final companyData =
                companyDoc.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(companyId)
                  .get(),
              builder: (context, userSnapshot) {

                if (!userSnapshot.hasData) {
                  return const SizedBox();
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                final isApproved = userData['isApproved'] ?? false;
                final isProfileComplete =
                    userData['isProfileComplete'] ?? false;
                final role = userData['role'];

                // Show only pending companies
                if (role != "company" ||
                    !isProfileComplete ||
                    isApproved) {
                  return const SizedBox();
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: companyData['profileImage'] != null
                          ? MemoryImage(
                              base64Decode(
                                  companyData['profileImage']),
                            )
                          : null,
                      child: companyData['profileImage'] == null
                          ? const Icon(Icons.business)
                          : null,
                    ),
                    title: Text(
                      companyData['name'] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text(companyData['address'] ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompanyDetailPage(
                            companyId: companyId,
                            companyData: companyData,
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
      },
    );
  }
}
// the code is modified 