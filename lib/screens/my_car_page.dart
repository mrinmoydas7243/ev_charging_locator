import 'package:flutter/material.dart';

class MyCarPage extends StatefulWidget {
  const MyCarPage({super.key});

  @override
  State<MyCarPage> createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _carBrandController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _batteryCapacityController = TextEditingController();

  bool _isCarAdded = false;

  @override
  void dispose() {
    _carBrandController.dispose();
    _carModelController.dispose();
    _carNumberController.dispose();
    _batteryCapacityController.dispose();
    super.dispose();
  }

  void _saveCarDetails() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCarAdded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Car details saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildCarDetailsCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Car Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _detailRow("Brand", _carBrandController.text),
            _detailRow("Model", _carModelController.text),
            _detailRow("Car Number", _carNumberController.text),
            _detailRow("Battery Capacity", "${_batteryCapacityController.text} kWh"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isCarAdded = false; // Allow user to update details
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCarForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Car Brand
            TextFormField(
              controller: _carBrandController,
              decoration: const InputDecoration(
                labelText: "Car Brand",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Please enter your car brand" : null,
            ),
            const SizedBox(height: 12),

            // Car Model
            TextFormField(
              controller: _carModelController,
              decoration: const InputDecoration(
                labelText: "Car Model",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.car_repair),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Please enter your car model" : null,
            ),
            const SizedBox(height: 12),

            // Car Number
            TextFormField(
              controller: _carNumberController,
              decoration: const InputDecoration(
                labelText: "Car Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Please enter your car number" : null,
            ),
            const SizedBox(height: 12),

            // Battery Capacity
            TextFormField(
              controller: _batteryCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Battery Capacity (kWh)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.battery_full),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Please enter battery capacity" : null,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveCarDetails,
              icon: const Icon(Icons.save),
              label: const Text("Save Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Car"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: _isCarAdded ? _buildCarDetailsCard() : _buildCarForm(),
    );
  }
}
