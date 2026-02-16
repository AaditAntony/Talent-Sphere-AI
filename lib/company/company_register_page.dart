// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CompanyRegisterPage extends StatefulWidget {
//   const CompanyRegisterPage({super.key});

//   @override
//   State<CompanyRegisterPage> createState() => _CompanyRegisterPageState();
// }

// class _CompanyRegisterPageState extends State<CompanyRegisterPage> {

//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final addressController = TextEditingController();
//   final foundedController = TextEditingController();

//   File? profileImageFile;
//   File? certificateImageFile;

//   String? profileBase64;
//   String? certificateBase64;

//   bool isLoading = false;

//   Future<void> pickImage(bool isProfile) async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70, // compress image
//     );

//     if (picked != null) {
//       File file = File(picked.path);
//       List<int> imageBytes = await file.readAsBytes();
//       String base64String = base64Encode(imageBytes);

//       setState(() {
//         if (isProfile) {
//           profileImageFile = file;
//           profileBase64 = base64String;
//         } else {
//           certificateImageFile = file;
//           certificateBase64 = base64String;
//         }
//       });
//     }
//   }

//   Future<void> registerCompany() async {

//     if (!_formKey.currentState!.validate()) return;

//     if (profileBase64 == null || certificateBase64 == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please upload all required images")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {

//       UserCredential credential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       final uid = credential.user!.uid;

//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         "name": nameController.text.trim(),
//         "email": emailController.text.trim(),
//         "address": addressController.text.trim(),
//         "foundedYear": foundedController.text.trim(),
//         "profileImage": profileBase64,
//         "certificateImage": certificateBase64,
//         "role": "company",
//         "isApproved": false,
//         "createdAt": Timestamp.now(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Registration successful. Wait for admin approval."),
//         ),
//       );

//       Navigator.pop(context);

//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(title: const Text("Company Registration")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [

//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Company Name"),
//                 validator: (v) => v!.isEmpty ? "Enter company name" : null,
//               ),

//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 validator: (v) => v!.isEmpty ? "Enter email" : null,
//               ),

//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 obscureText: true,
//                 validator: (v) =>
//                     v!.length < 6 ? "Minimum 6 characters required" : null,
//               ),

//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: addressController,
//                 decoration: const InputDecoration(labelText: "Address"),
//               ),

//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: foundedController,
//                 decoration: const InputDecoration(labelText: "Founded Year"),
//               ),

//               const SizedBox(height: 20),

//               // PROFILE IMAGE PREVIEW
//               profileImageFile != null
//                   ? Image.file(profileImageFile!, height: 120)
//                   : const Text("No Profile Image Selected"),

//               ElevatedButton(
//                 onPressed: () => pickImage(true),
//                 child: const Text("Upload Profile Image"),
//               ),

//               const SizedBox(height: 20),

//               // CERTIFICATE PREVIEW
//               certificateImageFile != null
//                   ? Image.file(certificateImageFile!, height: 120)
//                   : const Text("No Certificate Selected"),

//               ElevatedButton(
//                 onPressed: () => pickImage(false),
//                 child: const Text("Upload Certificate"),
//               ),

//               const SizedBox(height: 30),

//               ElevatedButton(
//                 onPressed: isLoading ? null : registerCompany,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text("Register Company"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
