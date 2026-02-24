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
      appBar: AppBar(
        title: const Text("My Profile"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Profile Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: data['profileImage'] != null
                            ? MemoryImage(base64Decode(data['profileImage']))
                            : null,
                        child: data['profileImage'] == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        data['name'] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const Divider(),

                const SizedBox(height: 25),

                // 🔥 AI PROFILE ANALYSIS
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile Strength: $finalScore%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              LinearProgressIndicator(
                                value: finalScore / 100,
                                minHeight: 8,
                              ),

                              const SizedBox(height: 12),

                              Text("Market Compatibility: $marketLevel"),

                              const SizedBox(height: 8),

                              Text(
                                _generateProfileMessage(finalScore),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
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

                const Divider(),

                const SizedBox(height: 25),

                // 🔹 Basic Info
                const Text(
                  "Basic Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                _buildInfoRow("Phone", data['phone']),
                _buildInfoRow("Education", data['education']),
                _buildInfoRow("Experience", data['experience']),

                const SizedBox(height: 30),

                const Divider(),

                const SizedBox(height: 25),

                // 🔹 Skills
                const Text(
                  "Skills",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 40),

                // 🔹 Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Logout"),
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
