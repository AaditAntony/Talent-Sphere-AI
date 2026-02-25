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
            child: Text(
              "No Approved Companies",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: approvedCompanies.length,
          itemBuilder: (context, index) {
            final userDoc = approvedCompanies[index];
            final companyId = userDoc.id;
            final userData = userDoc.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .get(),
              builder: (context, companySnapshot) {
                if (!companySnapshot.hasData || !companySnapshot.data!.exists) {
                  return const SizedBox();
                }

                final companyData =
                    companySnapshot.data!.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.green.withOpacity(0.08),
                            backgroundImage: companyData['profileImage'] != null
                                ? MemoryImage(
                                    base64Decode(companyData['profileImage']),
                                  )
                                : null,
                            child: companyData['profileImage'] == null
                                ? const Icon(
                                    Icons.business_outlined,
                                    color: Colors.green,
                                  )
                                : null,
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  companyData['name'] ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  userData['email'] ?? "",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Verified",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              "Address",
                              companyData['address'] ?? "N/A",
                            ),
                          ),
                          Expanded(
                            child: _infoItem(
                              "Founded Year",
                              companyData['foundedYear'] ?? "N/A",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
