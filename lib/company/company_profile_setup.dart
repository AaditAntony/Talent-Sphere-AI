import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_approval_page.dart';

class CompanyProfileSetupPage extends StatefulWidget {
  const CompanyProfileSetupPage({super.key});

  @override
  State<CompanyProfileSetupPage> createState() =>
      _CompanyProfileSetupPageState();
}

class _CompanyProfileSetupPageState
    extends State<CompanyProfileSetupPage> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final foundedController = TextEditingController();

  File? profileImageFile;
  File? certificateImageFile;

  String? profileBase64;
  String? certificateBase64;

  bool isLoading = false;

  Future<void> pickImage(bool isProfile) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
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

  Future<void> submitProfile() async {

    if (!_formKey.currentState!.validate()) return;

    if (profileBase64 == null || certificateBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload required images"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({

        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "foundedYear": foundedController.text.trim(),
        "profileImage": profileBase64,
        "certificateImage": certificateBase64,
        "isProfileComplete": true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WaitingApprovalPage(),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Company Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Text(
                "Complete Your Company Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Company Name"),
                validator: (v) =>
                    v!.isEmpty ? "Enter company name" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: addressController,
                decoration:
                    const InputDecoration(labelText: "Company Address"),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: foundedController,
                decoration:
                    const InputDecoration(labelText: "Founded Year"),
              ),

              const SizedBox(height: 20),

              profileImageFile != null
                  ? Image.file(profileImageFile!, height: 120)
                  : const Text("No Profile Image Selected"),

              ElevatedButton(
                onPressed: () => pickImage(true),
                child: const Text("Upload Profile Image"),
              ),

              const SizedBox(height: 20),

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
