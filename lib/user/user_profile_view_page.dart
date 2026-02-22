import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileViewPage extends StatelessWidget {
  const UserProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(
                child: Text("Profile Not Found"));
          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          final skills =
              List<String>.from(data['skills'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Center(
                  child: data['profileImageBase64'] != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              MemoryImage(
                            base64Decode(
                                data['profileImageBase64']),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          child:
                              Icon(Icons.person, size: 50),
                        ),
                ),

                const SizedBox(height: 20),

                Text(
                  data['name'] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text("Phone: ${data['phone']}"),

                const SizedBox(height: 20),

                const Text(
                  "Skills",
                  style: TextStyle(
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  children: skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),

                Text("Education: ${data['education']}"),

                const SizedBox(height: 10),

                Text("Experience: ${data['experience']}"),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance
                        .signOut();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}