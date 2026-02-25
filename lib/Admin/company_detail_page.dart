import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDetailPage extends StatelessWidget {
  final String companyId;
  final Map<String, dynamic> companyData;

  const CompanyDetailPage({
    super.key,
    required this.companyId,
    required this.companyData,
  });

  Future<void> approveCompany(BuildContext context) async {
    await FirebaseFirestore.instance.collection('users').doc(companyId).update({
      'isApproved': true,
    });

    Navigator.pop(context);
  }

  Future<void> rejectCompany(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(companyId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Company Review",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(companyId)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 950),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 60,
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
                                  size: 40,
                                  color: Color(0xFF2563EB),
                                )
                              : null,
                        ),

                        const SizedBox(width: 30),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyData['name'] ?? "No Name",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                userData['email'] ?? "N/A",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 30),

                    const Text(
                      "Company Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 25),

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

                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 30),

                    const Text(
                      "Company Certificate",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: companyData['certificateImage'] != null
                          ? Image.memory(
                              base64Decode(companyData['certificateImage']),
                            )
                          : const Text(
                              "No certificate uploaded",
                              style: TextStyle(color: Colors.black54),
                            ),
                    ),

                    const SizedBox(height: 50),

                    // 🔥 DECISION PANEL
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Administrative Decision",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => rejectCompany(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Reject",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              ElevatedButton(
                                onPressed: () => approveCompany(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Approve",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
