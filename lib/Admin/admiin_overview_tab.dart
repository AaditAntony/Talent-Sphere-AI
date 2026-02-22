import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  Future<int> getCount(CollectionReference collection) async {
    final snapshot = await collection.get();
    return snapshot.docs.length;
  }

  Future<int> getApprovedCompanies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'company')
        .where('isApproved', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  Future<int> getPendingCompanies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'company')
        .where('isApproved', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        getCount(FirebaseFirestore.instance.collection('users')),
        getCount(FirebaseFirestore.instance.collection('companies')),
        getApprovedCompanies(),
        getCount(FirebaseFirestore.instance.collection('jobs')),
        getCount(FirebaseFirestore.instance.collection('applications')),
        getPendingCompanies(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as List<int>;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              buildCard(
                "Total Users",
                data[0].toString(),
                Icons.people,
                Colors.blue,
              ),

              buildCard(
                "Total Companies",
                data[1].toString(),
                Icons.business,
                Colors.purple,
              ),

              buildCard(
                "Approved Companies",
                data[2].toString(),
                Icons.verified,
                Colors.green,
              ),

              buildCard(
                "Total Jobs",
                data[3].toString(),
                Icons.work,
                Colors.orange,
              ),

              buildCard(
                "Applications",
                data[4].toString(),
                Icons.description,
                Colors.teal,
              ),

              buildCard(
                "Pending Approvals",
                data[5].toString(),
                Icons.hourglass_top,
                Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
