import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/user/user_edit_profile_page.dart';

class UserProfileViewPage extends StatelessWidget {
  const UserProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("My Profile"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserEditProfilePage()),
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Profile Not Found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final skills = List<String>.from(data['skills'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFEEF2FF),
                        backgroundImage: data['profileImage'] != null
                            ? MemoryImage(base64Decode(data['profileImage']))
                            : null,
                        child: data['profileImage'] == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF6366F1),
                              )
                            : null,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        data['name'] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? "",
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// AI PROFILE ANALYSIS
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('jobs').get(),
                  builder: (context, jobSnapshot) {
                    if (!jobSnapshot.hasData) {
                      return const SizedBox();
                    }

                    final allJobs = jobSnapshot.data!.docs;

                    int totalMatches = 0;

                    for (var job in allJobs) {
                      final jobData = job.data() as Map<String, dynamic>;

                      final required = List<String>.from(
                        jobData['requiredSkills'] ?? [],
                      );

                      final matches = required
                          .where((skill) => skills.contains(skill))
                          .length;

                      totalMatches += matches;
                    }

                    final score = allJobs.isEmpty
                        ? 0
                        : (totalMatches / (allJobs.length * 3)) * 100;

                    final finalScore = score.clamp(0, 100).toInt();

                    String marketLevel;

                    if (finalScore >= 75) {
                      marketLevel = "High";
                    } else if (finalScore >= 50) {
                      marketLevel = "Moderate";
                    } else {
                      marketLevel = "Low";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AI Profile Analysis",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile Strength: $finalScore%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              LinearProgressIndicator(
                                value: finalScore / 100,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                "Market Compatibility: $marketLevel",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _generateProfileMessage(finalScore),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// BASIC INFO
                const Text(
                  "Basic Information",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Phone", data['phone']),
                      _buildInfoRow("Education", data['education']),
                      _buildInfoRow("Experience", data['experience']),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// SKILLS
                const Text(
                  "Skills",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(skill),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 35),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
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

  String _generateProfileMessage(int score) {
    if (score >= 75) {
      return "Your skills strongly align with current market demands.";
    } else if (score >= 50) {
      return "You have good alignment. Improving key skills will increase opportunities.";
    } else {
      return "Consider expanding your skill set to increase job compatibility.";
    }
  }
}
