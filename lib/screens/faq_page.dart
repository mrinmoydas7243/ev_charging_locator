import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample FAQs data
    final faqs = [
      {
        "question": "How do I book a charging station?",
        "answer": "Go to the Stations page, select a station, and choose your time slot to book."
      },
      {
        "question": "Can I cancel a booking?",
        "answer": "Yes, you can cancel an upcoming booking from the My Bookings section."
      },
      {
        "question": "How do I register my car?",
        "answer": "Go to the My Car section in your profile and add your car details."
      },
      {
        "question": "Is there a refund for canceled bookings?",
        "answer": "Refunds depend on the station's policy. Please check the station's details before booking."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: const Color(0xFF00C853),
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (ctx, i) {
          final faq = faqs[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                faq["question"]!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    faq["answer"]!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
