import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "App Settings",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ✅ Dark Mode Toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable or disable dark theme"),
            value: false,
            onChanged: (value) {
              // TODO: Implement Dark Mode later
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          // ✅ Notifications Toggle
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive updates & alerts"),
            value: true,
            onChanged: (value) {
              // TODO: Implement Notifications later
            },
            secondary: const Icon(Icons.notifications),
          ),

          // ✅ Change Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: const Text("Language"),
            subtitle: const Text("Choose app language"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Add language selection screen
            },
          ),
          const Divider(),

          // ✅ About App
          ListTile(
            leading: const Icon(Icons.info, color: Colors.orange),
            title: const Text("About App"),
            subtitle: const Text("Version 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "EV Charging Locator",
                applicationVersion: "1.0.1",
                applicationLegalese: "© 2025 Mrinmoy Das",
              );
            },
          ),

          // ✅ Logout Button
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Go back to previous page
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
