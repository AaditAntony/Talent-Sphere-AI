import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  Future<void> deleteUser(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 40),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              userData['name'] ?? "",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Email: ${userData['email'] ?? ""}"),

            const SizedBox(height: 10),
            Text("Skills: ${userData['skills'] ?? "Not Provided"}"),

            const SizedBox(height: 10),
            Text("Experience: ${userData['experience'] ?? "Not Provided"}"),

            const SizedBox(height: 20),

            userData['resumeUrl'] != null &&
                    userData['resumeUrl'] != ""
                ? TextButton(
                    onPressed: () {
                      // Opens resume link
                    },
                    child: const Text("View Resume"),
                  )
                : const Text("No Resume Uploaded"),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => deleteUser(context),
                child: const Text("Delete User"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
