import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class UserProfileSetupPage extends StatefulWidget {
  const UserProfileSetupPage({super.key});

  @override
  State<UserProfileSetupPage> createState() => _UserProfileSetupPageState();
}

class _UserProfileSetupPageState extends State<UserProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();

  Uint8List? profileImageBytes;
  String? profileImageBase64;

  String? resumeBase64;
  String? resumeFileName;

  bool isLoading = false;

  // ---------------- PROFILE IMAGE ----------------

  Future<void> pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null) {
      Uint8List bytes = result.files.first.bytes!;

      if (bytes.length > 300 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image must be below 300 KB")),
        );
        return;
      }

      setState(() {
        profileImageBytes = bytes;
        profileImageBase64 = base64Encode(bytes);
      });
    }
  }

  // ---------------- RESUME (PDF ONLY) ----------------

  Future<void> pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // 🔥 ONLY PDF
      withData: true,
    );

    if (result != null) {
      Uint8List bytes = result.files.first.bytes!;

      if (bytes.length > 300 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resume must be below 300 KB")),
        );
        return;
      }

      setState(() {
        resumeBase64 = base64Encode(bytes);
        resumeFileName = result.files.first.name;
      });
    }
  }

  // ---------------- SAVE PROFILE ----------------

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (profileImageBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload profile image")));
      return;
    }

    if (resumeBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload resume")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('userProfiles').doc(uid).set({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "skills": skillsController.text
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList(),
        "education": educationController.text.trim(),
        "experience": experienceController.text.trim(),
        "profileImageBase64": profileImageBase64,
        "resumeBase64": resumeBase64,
        "resumeFileName": resumeFileName,
        "createdAt": Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "isProfileComplete": true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Completed Successfully")),
      );

      // 🔥 DO NOT navigate manually
      // AuthWrapper will auto redirect

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageBytes != null
                      ? MemoryImage(profileImageBytes!)
                      : null,
                  child: profileImageBytes == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 10),
              const Text("Tap to upload profile image"),

              const SizedBox(height: 25),

              _buildField(nameController, "Full Name"),
              _buildField(phoneController, "Phone Number"),
              _buildField(skillsController, "Skills (comma separated)"),
              _buildField(educationController, "Education"),
              _buildField(experienceController, "Experience"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickResume,
                child: const Text("Upload Resume (PDF Only)"),
              ),

              if (resumeFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    resumeFileName!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? "Enter $label" : null,
      ),
    );
  }
}
