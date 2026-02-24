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

      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      final companyData = companyDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('jobs').add({
        "companyId": companyId,
        "companyName": companyData['name'],
        "companyLogo": companyData['profileImage'],
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
      skillsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Post a New Job",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Fill in the details below",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: titleController,
                decoration: _inputDecoration("Job Title"),
                validator: (v) => v!.isEmpty ? "Enter job title" : null,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Job Description"),
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      decoration: _inputDecoration("Location"),
                      validator: (v) => v!.isEmpty ? "Enter location" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: salaryController,
                      decoration: _inputDecoration("Salary"),
                      validator: (v) => v!.isEmpty ? "Enter salary" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: skillsController,
                decoration: _inputDecoration(
                  "Required Skills (comma separated)",
                ),
                validator: (v) => v!.isEmpty ? "Enter skills" : null,
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: jobType,
                decoration: _inputDecoration("Job Type"),
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : postJob,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Publish Job",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
