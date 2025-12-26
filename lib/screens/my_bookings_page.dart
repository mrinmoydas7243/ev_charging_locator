import 'package:flutter/material.dart';
import '../services/api_services/booking_api.dart';

class MyBookingsPage extends StatefulWidget {
  final String userId; // Pass user ID from profile

  const MyBookingsPage({super.key, required this.userId});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final BookingApi bookingApi = BookingApi();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await bookingApi.getBookingsByUser(widget.userId);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final success = await bookingApi.cancelBooking(bookingId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking cancelled successfully"),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings(); // Refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancellation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    "No bookings yet.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _bookings.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (ctx, i) {
                    final booking = _bookings[i];
                    final slot = booking['slot'] ?? {};
                    final station = slot['station'] ?? {};
                    
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.ev_station,
                          color: booking['status'] == 'CONFIRMED'
                              ? Colors.green
                              : booking['status'] == 'CANCELLED'
                                  ? Colors.red
                                  : Colors.grey,
                          size: 40,
                        ),
                        title: Text(station['name'] ?? 'Unknown Station'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Slot: ${slot['id']}"),
                            Text("Start: ${booking['startTime']}"),
                            Text("End: ${booking['endTime']}"),
                          ],
                        ),
                        trailing: booking['status'] == 'CONFIRMED'
                            ? IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _cancelBooking(booking['id'].toString()),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}