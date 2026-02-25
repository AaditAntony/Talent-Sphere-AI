import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talent_phere_ai/Admin/job_detail_page.dart';

class JobsMonitoringTab extends StatelessWidget {
  const JobsMonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!.docs;

        if (jobs.isEmpty) {
          return const Center(
            child: Text(
              "No Jobs Found",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final jobDoc = jobs[index];
            final jobData = jobDoc.data() as Map<String, dynamic>;
            final createdAt = (jobData['createdAt'] as Timestamp?)?.toDate();

            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        JobDetailPage(jobId: jobDoc.id, jobData: jobData),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.blue.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Job Title + Arrow
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            jobData['title'] ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Company Name
                    Text(
                      jobData['companyName'] ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 🔹 Meta Chips
                    Row(
                      children: [
                        _metaChip(
                          icon: Icons.location_on_outlined,
                          text: jobData['location'] ?? "",
                        ),
                        const SizedBox(width: 12),
                        _metaChip(
                          icon: Icons.attach_money,
                          text: jobData['salary'] ?? "",
                        ),
                        const SizedBox(width: 12),
                        _metaChip(
                          icon: Icons.work_outline,
                          text: jobData['jobType'] ?? "",
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 🔹 Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (createdAt != null)
                          Text(
                            "Posted ${DateFormat('dd MMM yyyy').format(createdAt)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('applications')
                              .where('jobId', isEqualTo: jobDoc.id)
                              .snapshots(),
                          builder: (context, appSnapshot) {
                            if (!appSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final count = appSnapshot.data!.docs.length;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "$count Applications",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _metaChip({required IconData icon, required String text}) {
    Color iconColor;
    Color backgroundColor;

    if (icon == Icons.location_on_outlined) {
      iconColor = const Color(0xFF2563EB); // Blue
      backgroundColor = iconColor.withOpacity(0.08);
    } else if (icon == Icons.attach_money) {
      iconColor = const Color(0xFF16A34A); // Green
      backgroundColor = iconColor.withOpacity(0.08);
    } else if (icon == Icons.work_outline) {
      iconColor = const Color(0xFF7C3AED); // Violet
      backgroundColor = iconColor.withOpacity(0.08);
    } else {
      iconColor = Colors.blueGrey;
      backgroundColor = iconColor.withOpacity(0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
