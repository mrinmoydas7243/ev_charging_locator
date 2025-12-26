import 'package:flutter/material.dart';
import 'package:ev_charging_locator/screens/my_car_page.dart';
import 'package:ev_charging_locator/screens/my_bookings_page.dart';
import 'package:ev_charging_locator/screens/faq_page.dart';
import 'package:ev_charging_locator/screens/feedback_page.dart';
import 'booking_page.dart'; // Make sure this file exists

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  SizedBox(width: 15),

                  // User Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mrinmoy Das",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "mrinmoy@example.com",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // My Bookings
                  // In profile_page.dart, update the My Bookings ListTile
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: Colors.green),
                    title: const Text("My Bookings"),
                    subtitle: const Text("View your past & upcoming bookings"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsPage(
                            userId: "1", 
                            // TODO: Replace with actual user ID from auth
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // My Vehicle Details
                  ListTile(
                    leading:
                        const Icon(Icons.directions_car, color: Colors.blue),
                    title: const Text("My Vehicle"),
                    subtitle:
                        const Text("Manage your registered Vehicle details"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCarPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // FAQ
                  ListTile(
                    leading:
                        const Icon(Icons.help_outline, color: Colors.orange),
                    title: const Text("FAQ"),
                    subtitle: const Text("Frequently asked questions"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // Send Feedback
                  ListTile(
                    leading: const Icon(Icons.feedback, color: Colors.purple),
                    title: const Text("Send Feedback"),
                    subtitle: const Text("Share your thoughts & suggestions"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // Online Booking & Payment
                  ListTile(
                    leading: const Icon(Icons.book_online, color: Colors.blue),
                    title: const Text("Online Booking & Payment"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // Logout Button
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
