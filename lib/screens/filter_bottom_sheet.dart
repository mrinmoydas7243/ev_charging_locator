import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Stations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Charger Type"),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            children: [
              Chip(label: Text("Fast")),
              Chip(label: Text("Normal")),
              Chip(label: Text("Tesla")),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Availability"),
          const SizedBox(height: 10),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Only Available Chargers"),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Apply Filter"),
            ),
          )
        ],
      ),
    );
  }
}
