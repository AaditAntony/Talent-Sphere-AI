
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEditProfilePage extends StatefulWidget {
  const UserEditProfilePage({super.key});

  @override
  State<UserEditProfilePage> createState() => _UserEditProfilePageState();
}

class _UserEditProfilePageState extends State<UserEditProfilePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final phoneController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();
  final skillController = TextEditingController();

  List<String> skills = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      phoneController.text = data['phone'] ?? "";
      educationController.text = data['education'] ?? "";
      experienceController.text = data['experience'] ?? "";

      skills = List<String>.from(data['skills'] ?? []);
    }

    setState(() => isLoading = false);
  }

  void addSkill() {
    final skill = skillController.text.trim();

    if (skill.isEmpty) return;

    if (skills.contains(skill)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Skill already added")));
      return;
    }

    setState(() {
      skills.add(skill);
      skillController.clear();
    });
  }

  void removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
    });
  }

  Future<void> saveProfile() async {
    await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(uid)
        .update({
          "phone": phoneController.text.trim(),
          "education": educationController.text.trim(),
          "experience": experienceController.text.trim(),
          "skills": skills,
        });

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: educationController,
              decoration: const InputDecoration(labelText: "Education"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: experienceController,
              decoration: const InputDecoration(labelText: "Experience"),
            ),

            const SizedBox(height: 25),

            const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillController,
                    decoration: const InputDecoration(
                      hintText: "Add skill and press +",
                    ),
                    onSubmitted: (_) => addSkill(),
                  ),
                ),
                IconButton(onPressed: addSkill, icon: const Icon(Icons.add)),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => removeSkill(skill),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
