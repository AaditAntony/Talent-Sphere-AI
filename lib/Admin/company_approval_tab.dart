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
          .collection('users')
          .where('role', isEqualTo: 'company')
          .where('isProfileComplete', isEqualTo: true)
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, userSnapshot) {

        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingUsers = userSnapshot.data!.docs;

        if (pendingUsers.isEmpty) {
          return const Center(child: Text("No Pending Companies"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {

            final userDoc = pendingUsers[index];
            final companyId = userDoc.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('companies')
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

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      companyData['profileImage'] != null
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
                    trailing:
                    const Icon(Icons.arrow_forward_ios),
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
