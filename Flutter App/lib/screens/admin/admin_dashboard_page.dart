import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> get complaintsStream {
    return FirebaseFirestore.instance.collection('complaints').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: complaintsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final total = docs.length;
          final resolved = docs.where((d) => d['status'] == 'Resolved').length;
          final inProgress =
              docs.where((d) => d['status'] == 'In Progress').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Admin 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Here are your complaint stats:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                /// Row with 2 cards
                Row(
                  children: [
                    _buildCard(
                      title: 'Complaints Received',
                      count: '$total',
                      icon: Icons.mail,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildCard(
                      title: 'Complaints Solved',
                      count: '$resolved',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Second row, single card
                _buildCard(
                  title: 'Complaints In Progress',
                  count: '$inProgress',
                  icon: Icons.loop,
                  color: Colors.orange,
                  fullWidth: true,
                ),

                const SizedBox(height: 24),

                /// Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to complaints list
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All Complaints'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: Container(
        width: fullWidth ? double.infinity : null,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
