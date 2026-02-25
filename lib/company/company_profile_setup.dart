import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talent_phere_ai/company/waiting_approval_screen.dart';

class CompanyProfileSetupPage extends StatefulWidget {
  const CompanyProfileSetupPage({super.key});

  @override
  State<CompanyProfileSetupPage> createState() =>
      _CompanyProfileSetupPageState();
}

class _CompanyProfileSetupPageState extends State<CompanyProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final foundedController = TextEditingController();

  File? profileImageFile;
  File? certificateImageFile;

  String? profileBase64;
  String? certificateBase64;

  bool isLoading = false;

  // 🔹 Pick image and convert to Base64
  Future<void> pickImage(bool isProfile) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compress
    );

    if (picked != null) {
      File file = File(picked.path);
      List<int> bytes = await file.readAsBytes();
      String base64String = base64Encode(bytes);

      setState(() {
        if (isProfile) {
          profileImageFile = file;
          profileBase64 = base64String;
        } else {
          certificateImageFile = file;
          certificateBase64 = base64String;
        }
      });
    }
  }

  // 🔹 Submit company details
  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (profileBase64 == null || certificateBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload all required images")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1️⃣ Create company document
      await FirebaseFirestore.instance.collection('companies').doc(uid).set({
        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "foundedYear": foundedController.text.trim(),
        "profileImage": profileBase64,
        "certificateImage": certificateBase64,
        "createdAt": Timestamp.now(),
      });

      // 2️⃣ Update user flags
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "isProfileComplete": true,
      });

      // 3️⃣ Navigate to waiting approval
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WaitingApprovalPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Company Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter Your Company Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Company Name"),
                validator: (v) => v!.isEmpty ? "Enter company name" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Company Address"),
                validator: (v) => v!.isEmpty ? "Enter company address" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: foundedController,
                decoration: const InputDecoration(labelText: "Founded Year"),
                validator: (v) => v!.isEmpty ? "Enter founded year" : null,
              ),

              const SizedBox(height: 25),

              // 🔹 Profile Image Preview
              profileImageFile != null
                  ? Image.file(profileImageFile!, height: 120)
                  : const Text("No Profile Image Selected"),

              ElevatedButton(
                onPressed: () => pickImage(true),
                child: const Text("Upload Profile Image"),
              ),

              const SizedBox(height: 20),

              // 🔹 Certificate Preview
              certificateImageFile != null
                  ? Image.file(certificateImageFile!, height: 120)
                  : const Text("No Certificate Selected"),

              ElevatedButton(
                onPressed: () => pickImage(false),
                child: const Text("Upload Certificate"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : submitProfile,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Submit for Approval"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// working