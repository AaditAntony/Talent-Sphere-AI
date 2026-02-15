import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompanyApprovalTab extends StatelessWidget {
  const CompanyApprovalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final companies = snapshot.data!.docs;

        if (companies.isEmpty) {
          return const Center(child: Text("No Pending Approvals"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final data = companies[index];

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: data['profileImageUrl'] != null &&
                        data['profileImageUrl'] != ""
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(data['profileImageUrl']),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.business),
                      ),
                title: Text(
                  data['companyName'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['email']),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanyDetailPage(
                        companyId: data.id,
                        companyData: data.data(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
