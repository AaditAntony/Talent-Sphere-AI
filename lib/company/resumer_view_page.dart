import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import: uses dart:html on web, stub on other platforms
import 'pdf_opener_stub.dart'
    if (dart.library.html) 'pdf_opener_web.dart';

// Mobile-only imports (guarded by kIsWeb check at runtime)
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ResumeViewerPage extends StatefulWidget {
  final String base64Pdf;

  const ResumeViewerPage({super.key, required this.base64Pdf});

  @override
  State<ResumeViewerPage> createState() => _ResumeViewerPageState();
}

class _ResumeViewerPageState extends State<ResumeViewerPage> {
  String? filePath;
  bool _openedInBrowser = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Open immediately in a new browser tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openPdfInBrowser(widget.base64Pdf);
        setState(() => _openedInBrowser = true);
      });
    } else {
      _loadPdfMobile();
    }
  }

  Future<void> _loadPdfMobile() async {
    try {
      final bytes = base64Decode(widget.base64Pdf);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/resume.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) setState(() => filePath = file.path);
    } catch (e) {
      debugPrint('Error loading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: kIsWeb ? _buildWebBody() : _buildMobileBody(),
    );
  }

  Widget _buildWebBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFF2563EB)),
          const SizedBox(height: 24),
          Text(
            _openedInBrowser
                ? '✅ Resume opened in a new tab!'
                : 'Opening resume...',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'If the PDF did not open, click the button below.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () {
              openPdfInBrowser(widget.base64Pdf);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Resume PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    return filePath == null
        ? const Center(child: CircularProgressIndicator())
        : PDFView(filePath: filePath!);
  }
}
// working