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
        const SnackBar(content: Text("Please upload all required images")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('companies').doc(uid).set({
        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "foundedYear": foundedController.text.trim(),
        "profileImage": profileBase64,
        "certificateImage": certificateBase64,
        "createdAt": Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "isProfileComplete": true,
      });

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
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("Complete Company Profile"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 15,
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.business_center,
                    size: 50,
                    color: Color(0xFF7C3AED),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Company Setup",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Company Name",
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (v) => v!.isEmpty ? "Enter company name" : null,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Company Address",
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter company address" : null,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: foundedController,
                    decoration: const InputDecoration(
                      labelText: "Founded Year",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (v) => v!.isEmpty ? "Enter founded year" : null,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Company Logo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  profileImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(profileImageFile!, height: 120),
                        )
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: const Center(
                            child: Text("No Profile Image Selected"),
                          ),
                        ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () => pickImage(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Upload Profile Image"),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Company Certificate",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  certificateImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(certificateImageFile!, height: 120),
                        )
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: const Center(
                            child: Text("No Certificate Selected"),
                          ),
                        ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () => pickImage(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Upload Certificate"),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitProfile,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                      ),

                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit for Approval",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
