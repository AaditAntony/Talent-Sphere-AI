import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedCompanyTab extends StatelessWidget {
  const ApprovedCompanyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'company')
          .where('isApproved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final approvedCompanies = snapshot.data!.docs;

        if (approvedCompanies.isEmpty) {
          return const Center(
              child: Text("No Approved Companies"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: approvedCompanies.length,
          itemBuilder: (context, index) {

            final userDoc = approvedCompanies[index];
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
                  margin:
                      const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: companyData['profileImage'] != null
                        ? CircleAvatar(
                            backgroundImage:
                                MemoryImage(
                              base64Decode(
                                  companyData['profileImage']),
                            ),
                          )
                        : const CircleAvatar(
                            child:
                                Icon(Icons.business),
                          ),
                    title: Text(
                      companyData['name'] ?? "",
                      style: const TextStyle(
                          fontWeight:
                              FontWeight.bold),
                    ),
                    subtitle: Text(
                        companyData['address'] ?? ""),
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