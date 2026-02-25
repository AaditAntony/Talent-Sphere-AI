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
          padding: const EdgeInsets.all(30),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
            childAspectRatio: 1.5,
            children: [
              buildCard("Total Users", data[0], Icons.people_outline),
              buildCard("Total Companies", data[1], Icons.business_outlined),
              buildCard("Approved Companies", data[2], Icons.verified_outlined),
              buildCard("Total Jobs", data[3], Icons.work_outline),
              buildCard("Applications", data[4], Icons.description_outlined),
              buildCard("Pending Approvals", data[5], Icons.hourglass_empty),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(String title, int value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF2563EB)),
            ),

            const SizedBox(height: 18),

            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
