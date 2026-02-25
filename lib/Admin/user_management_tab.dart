import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/Admin/user_detail_page.dart';

class UserManagementTab extends StatelessWidget {
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(
            child: Text(
              "No Users Found",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            final userId = userDoc.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('userProfiles')
                  .doc(userId)
                  .get(),
              builder: (context, profileSnapshot) {
                if (!profileSnapshot.hasData) {
                  return const SizedBox();
                }

                final profileExists = profileSnapshot.data!.exists;
                final profileData = profileExists
                    ? profileSnapshot.data!.data() as Map<String, dynamic>
                    : null;

                final skills = profileData != null
                    ? List<String>.from(profileData['skills'] ?? [])
                    : [];

                final hasResume = profileData?['resumeBase64'] != null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(
                          0xFF2563EB,
                        ).withOpacity(0.08),
                        backgroundImage:
                            profileData != null &&
                                profileData['profileImageBase64'] != null
                            ? MemoryImage(
                                base64Decode(profileData['profileImageBase64']),
                              )
                            : null,
                        child:
                            profileData == null ||
                                profileData['profileImageBase64'] == null
                            ? const Icon(
                                Icons.person_outline,
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
                              userData['email'] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            if (skills.isNotEmpty)
                              Text(
                                skills.take(3).join(', '),
                                style: const TextStyle(color: Colors.black54),
                              ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                if (hasResume)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Text(
                                      "Resume Uploaded",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                const SizedBox(width: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: userData['isProfileComplete'] == true
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    userData['isProfileComplete'] == true
                                        ? "Profile Complete"
                                        : "Incomplete",
                                    style: TextStyle(
                                      color:
                                          userData['isProfileComplete'] == true
                                          ? Colors.blue
                                          : Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: Color(0xFF2563EB),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserDetailPage(userId: userId, userData: {}),
                            ),
                          );
                        },
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
}
