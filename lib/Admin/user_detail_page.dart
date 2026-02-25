import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  Future<void> deleteUser(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(userId)
        .delete();
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text("User Details"),
        elevation: 0,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: Future.wait([
          FirebaseFirestore.instance.collection('users').doc(userId).get(),
          FirebaseFirestore.instance
              .collection('userProfiles')
              .doc(userId)
              .get(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDoc = snapshot.data![0];
          final profileDoc = snapshot.data![1];

          if (!userDoc.exists || !profileDoc.exists) {
            return const Center(child: Text("User Data Not Found"));
          }

          final userData = userDoc.data() as Map<String, dynamic>;
          final profileData = profileDoc.data() as Map<String, dynamic>;

          final skills = List<String>.from(profileData['skills'] ?? []);
          final hasResume = profileData['resumeBase64'] != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(
                          0xFF2563EB,
                        ).withOpacity(0.1),
                        backgroundImage:
                            profileData['profileImageBase64'] != null
                            ? MemoryImage(
                                base64Decode(profileData['profileImageBase64']),
                              )
                            : null,
                        child: profileData['profileImageBase64'] == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF2563EB),
                              )
                            : null,
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData['name'] ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userData['email'] ?? "",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Phone: ${profileData['phone'] ?? ""}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Professional Info
                _sectionCard(
                  title: "Professional Information",
                  child: Column(
                    children: [
                      _infoRow("Education", profileData['education']),
                      _infoRow("Experience", profileData['experience']),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Skills
                _sectionCard(
                  title: "Skills",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: skills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: const Color(
                              0xFF2563EB,
                            ).withOpacity(0.08),
                            labelStyle: const TextStyle(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Resume Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Icon(
                        hasResume ? Icons.check_circle : Icons.cancel,
                        color: hasResume ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        hasResume ? "Resume Uploaded" : "Resume Not Uploaded",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasResume ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Delete Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Delete User",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => deleteUser(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          blurRadius: 15,
          offset: const Offset(0, 6),
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value ?? "",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
