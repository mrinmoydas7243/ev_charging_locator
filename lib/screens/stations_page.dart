import 'package:flutter/material.dart';

class StationsPage extends StatelessWidget {
  final List<Map<String, String>> stations = [
    {
      "name": "Tata Power EV Charging Station",
      "location": "Salt Lake, Kolkata",
      "status": "Available",
      "distance": "2.5 km"
    },
    {
      "name": "MG ZS EV Charging Hub",
      "location": "Park Street, Kolkata",
      "status": "Busy",
      "distance": "4.2 km"
    },
    {
      "name": "Hero Electric Station",
      "location": "New Town, Kolkata",
      "status": "Available",
      "distance": "5.8 km"
    },
    {
      "name": "Ather Grid Charging Point",
      "location": "Howrah, Kolkata",
      "status": "Available",
      "distance": "6.1 km"
    },
  ];

  StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby EV Charging Stations"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Icon(
                Icons.ev_station,
                color: station["status"] == "Available" ? Colors.green : Colors.red,
                size: 35,
              ),
              title: Text(
                station["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${station["location"]}\nDistance: ${station["distance"]}"),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: station["status"] == "Available" ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  station["status"]!,
                  style: TextStyle(
                    color: station["status"] == "Available" ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Opening ${station["name"]} on map..."),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
