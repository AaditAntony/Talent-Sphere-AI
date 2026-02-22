import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantDetailPage extends StatelessWidget {
  final String applicationId;
  final Map<String, dynamic> applicationData;

  const ApplicantDetailPage({
    super.key,
    required this.applicationId,
    required this.applicationData,
  });

  Future<void> updateStatus(
      BuildContext context, String status) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({"status": status});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final skills =
        List<String>.from(applicationData['userSkills'] ?? []);
    final profileImage =
        applicationData['userProfileImage'];
    final status =
        applicationData['status'] ?? "pending";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applicant Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Center(
              child: profileImage != null &&
                      profileImage != ""
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          MemoryImage(
                        base64Decode(profileImage),
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
              applicationData['userName'] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              applicationData['userEmail'] ?? "",
              style:
                  const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Text(
              "Applied For: ${applicationData['jobTitle']}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

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

            const Text(
              "Resume",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Resume Preview"),
                    content: const Text(
                        "Resume file stored successfully.\n(Preview not implemented in demo version)"),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text("Close"),
                      )
                    ],
                  ),
                );
              },
              child: const Text("View Resume"),
            ),

            const SizedBox(height: 20),

            Text(
              "Status: ${status.toUpperCase()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == "accepted"
                    ? Colors.green
                    : status == "rejected"
                        ? Colors.red
                        : Colors.orange,
              ),
            ),

            const SizedBox(height: 25),

            if (status == "pending")
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () =>
                        updateStatus(context,
                            "accepted"),
                    child: const Text("Accept"),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () =>
                        updateStatus(context,
                            "rejected"),
                    child: const Text("Reject"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
