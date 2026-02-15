class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as Map<String, int>;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              buildCard("Total Users", data['users']!),
              buildCard("Total Companies", data['companies']!),
              buildCard("Approved Companies", data['approvedCompanies']!),
              buildCard("Total Jobs", data['jobs']!),
              buildCard("Total Applications", data['applications']!),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, int>> getCounts() async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();

    final companies = await FirebaseFirestore.instance
        .collection('companies')
        .get();

    final approvedCompanies = await FirebaseFirestore.instance
        .collection('companies')
        .where('isApproved', isEqualTo: true)
        .get();

    final jobs = await FirebaseFirestore.instance
        .collection('jobs')
        .get();

    final applications = await FirebaseFirestore.instance
        .collection('applications')
        .get();

    return {
      'users': users.size,
      'companies': companies.size,
      'approvedCompanies': approvedCompanies.size,
      'jobs': jobs.size,
      'applications': applications.size,
    };
  }

  Widget buildCard(String title, int count) {
    return Container(
      width: 250,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
