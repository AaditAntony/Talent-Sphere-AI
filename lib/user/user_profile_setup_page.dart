import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:talent_phere_ai/user/user_dashboard_page.dart';


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

  // Profile Image
  Uint8List? profileImageBytes;
  String? profileImageBase64;

  // Resume
  String? resumeBase64;
  String? resumeFileName;

  bool isLoading = false;

  // ---------------- PROFILE IMAGE PICKER ----------------

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

  // ---------------- RESUME PICKER ----------------

  Future<void> pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Completed Successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboardPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
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

              // Profile Image
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

              const SizedBox(height: 8),
              const Text("Tap to upload profile image"),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Enter full name" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: skillsController,
                decoration: const InputDecoration(labelText: "Skills"),
                validator: (v) => v!.isEmpty ? "Enter skills" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: educationController,
                decoration: const InputDecoration(labelText: "Education"),
                validator: (v) => v!.isEmpty ? "Enter education" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: "Experience"),
                validator: (v) => v!.isEmpty ? "Enter experience" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickResume,
                child: const Text("Upload Resume (PDF/DOC)"),
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

              ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//working