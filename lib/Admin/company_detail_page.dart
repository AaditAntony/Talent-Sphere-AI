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
      appBar: AppBar(title: const Text("Company Details")),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Profile Image
                Center(
                  child: companyData['profileImage'] != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: MemoryImage(
                            base64Decode(companyData['profileImage']),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.business, size: 40),
                        ),
                ),

                const SizedBox(height: 20),

                Text(
                  companyData['name'] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),
                Text("Email: ${userData['email'] ?? "N/A"}"),

                const SizedBox(height: 10),
                Text("Address: ${companyData['address'] ?? "N/A"}"),

                const SizedBox(height: 10),
                Text("Founded: ${companyData['foundedYear'] ?? "N/A"}"),

                const SizedBox(height: 20),

                const Text(
                  "Company Certificate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                companyData['certificateImage'] != null
                    ? Image.memory(
                        base64Decode(companyData['certificateImage']),
                      )
                    : const Text("No certificate uploaded"),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => approveCompany(context),
                      child: const Text("Approve"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => rejectCompany(context),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// the code is modified