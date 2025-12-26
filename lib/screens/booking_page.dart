import 'package:flutter/material.dart';
import '../services/api_services/booking_api.dart';
import '../services/api_services/slot_api.dart';

class BookingPage extends StatefulWidget {
  final String? stationId;
  final String? stationName;

  const BookingPage({super.key, this.stationId, this.stationName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Booking selections
  String? _selectedStationId;
  String? _selectedSlotId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration _selectedDuration = const Duration(hours: 1);

  final BookingApi bookingApi = BookingApi();
  final SlotApi slotApi = SlotApi();
  List<dynamic> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStationId = widget.stationId;
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedStationId == null) return;
    
    try {
      setState(() => _isLoading = true);
      _availableSlots = await slotApi.getAvailableSlots(_selectedStationId!);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load slots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Pick Date
  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Pick Time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // Confirm Booking
  Future<void> _confirmBooking() async {
    if (_selectedStationId == null ||
        _selectedSlotId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final startTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      final endTime = startTime.add(_selectedDuration);

      final bookingData = {
        'userId': 1, // TODO: Replace with actual user ID from auth
        'slotId': int.parse(_selectedSlotId!),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };

      final result = await bookingApi.createBooking(bookingData);
      
      setState(() => _isLoading = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Booking Confirmed"),
          content: Text("Booking ID: ${result['id']}\nStatus: ${result['status']}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stationName ?? "Book Charging Slot"),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Station Info
                  if (widget.stationName != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.ev_station, color: Colors.green),
                        title: Text(widget.stationName!),
                        subtitle: const Text("Selected Station"),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Slot Selection
                  _availableSlots.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No available slots"),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Select Slot",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.electrical_services),
                          ),
                          items: _availableSlots.map((slot) {
                            return DropdownMenuItem(
                              value: slot['id'].toString(),
                              child: Text("Slot #${slot['id']} - ${slot['status']}"),
                            );
                          }).toList(),
                          value: _selectedSlotId,
                          onChanged: (value) => setState(() => _selectedSlotId = value),
                        ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    leading: const Icon(Icons.calendar_today, color: Colors.green),
                    title: Text(_selectedDate == null
                        ? "Select Date"
                        : "${_selectedDate!.toLocal()}".split(' ')[0]),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),

                  // Time Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    leading: const Icon(Icons.access_time, color: Colors.green),
                    title: Text(_selectedTime == null
                        ? "Select Time"
                        : _selectedTime!.format(context)),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 16),

                  // Duration Selection
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    leading: const Icon(Icons.timer, color: Colors.green),
                    title: const Text("Duration"),
                    trailing: DropdownButton<Duration>(
                      value: _selectedDuration,
                      items: const [
                        DropdownMenuItem(
                          value: Duration(hours: 1),
                          child: Text("1 hour"),
                        ),
                        DropdownMenuItem(
                          value: Duration(hours: 2),
                          child: Text("2 hours"),
                        ),
                        DropdownMenuItem(
                          value: Duration(hours: 3),
                          child: Text("3 hours"),
                        ),
                      ],
                      onChanged: (value) => setState(() => _selectedDuration = value!),
                    ),
                  ),

                  const Spacer(),

                  // Confirm Booking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}