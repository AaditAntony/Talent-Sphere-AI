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
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BASIC INFO CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: educationController,
                    decoration: const InputDecoration(
                      labelText: "Education",
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: "Experience",
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// SKILLS SECTION
            const Text(
              "Skills",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillController,
                    decoration: const InputDecoration(
                      hintText: "Add skill",
                      prefixIcon: Icon(Icons.auto_awesome_outlined),
                    ),
                    onSubmitted: (_) => addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: addSkill,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1)),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: const TextStyle(color: Color(0xFF6366F1)),
                      ),

                      const SizedBox(width: 6),

                      GestureDetector(
                        onTap: () => removeSkill(skill),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 35),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
