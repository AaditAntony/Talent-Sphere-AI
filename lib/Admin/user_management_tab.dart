import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementTab extends StatelessWidget {
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(
              child: Text("No Users Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {

            final userDoc = users[index];
            final userData =
                userDoc.data()
                    as Map<String, dynamic>;

            return Card(
              elevation: 4,
              margin:
                  const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  userData['email'] ?? "",
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.bold),
                ),
                subtitle: Text(
                  "Profile Complete: ${userData['isProfileComplete'] ?? false}",
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(userDoc.id)
                        .delete();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}