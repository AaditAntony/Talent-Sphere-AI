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
          return const Center(
            child: Text(
              "No Pending Companies",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {
            final userDoc = pendingUsers[index];
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

                final createdAt = userData['createdAt'] != null
                    ? (userData['createdAt'] as Timestamp).toDate()
                    : null;

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
                            backgroundColor: const Color(
                              0xFF2563EB,
                            ).withOpacity(0.08),
                            backgroundImage: companyData['profileImage'] != null
                                ? MemoryImage(
                                    base64Decode(companyData['profileImage']),
                                  )
                                : null,
                            child: companyData['profileImage'] == null
                                ? const Icon(
                                    Icons.business_outlined,
                                    color: Color(0xFF2563EB),
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

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Pending Approval",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(12),
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF2563EB),
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
                              "Founded",
                              companyData['foundedYear'] ?? "N/A",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (createdAt != null)
                        _infoItem(
                          "Submitted On",
                          "${createdAt.day}/${createdAt.month}/${createdAt.year}",
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
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
