import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMyApplicationsPage extends StatelessWidget {
  const UserMyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("My Applications"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),

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
            return const Center(
              child: Text(
                "No Applications Yet",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final appDoc = applications[index];
              final appData = appDoc.data() as Map<String, dynamic>;

              final status = appData['status'] ?? "pending";

              Color statusColor;
              IconData statusIcon;

              if (status == "accepted") {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
              } else if (status == "rejected") {
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
              } else {
                statusColor = Colors.orange;
                statusIcon = Icons.hourglass_bottom;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Job Title
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            color: Color(0xFF6366F1),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              appData['jobTitle'] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Company Name
                      Row(
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            appData['companyName'] ?? "",
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),

                            const SizedBox(width: 6),

                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
