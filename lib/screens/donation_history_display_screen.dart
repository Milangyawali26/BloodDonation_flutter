import 'package:flutter/material.dart';

class DonationHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> donationHistory;
  const DonationHistoryScreen({super.key, required this.donationHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
      ),
      body: ListView.builder(
        itemCount: donationHistory.length,
        itemBuilder: (context, index) {
          var donation = donationHistory[index];
          return ListTile(
            title: Text('Date: ${donation['date']}'),
            subtitle: Text('Volume: ${donation['volume']} c.c.'),
          );
        },
      ),
    );
  }
}
