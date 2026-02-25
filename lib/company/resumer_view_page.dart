import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class ResumeViewerPage extends StatefulWidget {
  final String base64Pdf;

  const ResumeViewerPage({super.key, required this.base64Pdf});

  @override
  State<ResumeViewerPage> createState() => _ResumeViewerPageState();
}

class _ResumeViewerPageState extends State<ResumeViewerPage> {
  String? filePath;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    final bytes = base64Decode(widget.base64Pdf);

    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/resume.pdf");

    await file.writeAsBytes(bytes);

    setState(() {
      filePath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resume")),
      body: filePath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(filePath: filePath!),
    );
  }
}
// working