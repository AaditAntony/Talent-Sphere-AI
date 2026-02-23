import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyPostJobPage extends StatefulWidget {
  const CompanyPostJobPage({super.key});

  @override
  State<CompanyPostJobPage> createState() => _CompanyPostJobPageState();
}

class _CompanyPostJobPageState extends State<CompanyPostJobPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  final skillsController = TextEditingController();

  String jobType = "Full-time";
  bool isLoading = false;

  final List<String> jobTypes = [
    "Full-time",
    "Part-time",
    "Remote",
    "Internship",
  ];

  Future<void> postJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final companyId = FirebaseAuth.instance.currentUser!.uid;

      // 🔹 Fetch company details
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      if (!companyDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company profile not found")),
        );
        setState(() => isLoading = false);
        return;
      }

      final companyData = companyDoc.data() as Map<String, dynamic>;

      final companyName = companyData['name'] ?? "Company";

      final companyLogo = companyData['profileImage'] ?? "";

      // 🔹 Save job with company info
      await FirebaseFirestore.instance.collection('jobs').add({
        "companyId": companyId,
        "companyName": companyName,
        "companyLogo": companyLogo,

        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "location": locationController.text.trim(),
        "salary": salaryController.text.trim(),
        "requiredSkills": skillsController.text
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList(),
        "jobType": jobType,
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Job Posted Successfully")));

      _formKey.currentState!.reset();
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
      appBar: AppBar(title: const Text("Post New Job")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Job Title"),
                validator: (v) => v!.isEmpty ? "Enter job title" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Job Description"),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Enter job description" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (v) => v!.isEmpty ? "Enter location" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: "Salary"),
                validator: (v) => v!.isEmpty ? "Enter salary" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: skillsController,
                decoration: const InputDecoration(labelText: "Required Skills"),
                validator: (v) => v!.isEmpty ? "Enter required skills" : null,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: jobType,
                decoration: const InputDecoration(labelText: "Job Type"),
                items: jobTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    jobType = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : postJob,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Post Job"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
