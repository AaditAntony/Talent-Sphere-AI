import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyRejectedPage extends StatelessWidget {
  const CompanyRejectedPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper will automatically redirect to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔴 Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 60,
                  color: Color(0xFFDC2626),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Application Not Approved',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: const Text(
                  'After careful review, your company profile did not meet our verification requirements at this time.\n\nIf you believe this was an error, please contact our support team for further assistance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
