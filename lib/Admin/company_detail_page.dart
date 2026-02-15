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
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .update({'isApproved': true});

    Navigator.pop(context);
  }

  Future<void> rejectCompany(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: companyData['profileImageUrl'] != null &&
                      companyData['profileImageUrl'] != ""
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage(companyData['profileImageUrl']),
                    )
                  : const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.business, size: 40),
                    ),
            ),

            const SizedBox(height: 20),

            Text(
              companyData['companyName'],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Text("Email: ${companyData['email']}"),
            const SizedBox(height: 10),
            Text("Address: ${companyData['address']}"),
            const SizedBox(height: 10),
            Text("Founded: ${companyData['foundedYear']}"),

            const SizedBox(height: 20),

            const Text(
              "Company Certificate",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            companyData['certificateUrl'] != null &&
                    companyData['certificateUrl'] != ""
                ? Image.network(companyData['certificateUrl'])
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
            )
          ],
        ),
      ),
    );
  }
}
