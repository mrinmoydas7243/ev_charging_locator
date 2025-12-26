import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/ev_station.dart';
import '../services/station_repository.dart';
import '../secrets.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'stations_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'package:ev_charging_locator/services/api_services/station_api.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: unused_field
  final PanelController _panel = PanelController();
  GoogleMapController? _map;
  LatLng? _currentLatLng;

  final _repo = StationRepository();
  final StationApi _stationApi = StationApi(); // Initialize StationApi
  List<EVStation> _all = [];
  List<EVStation> _filtered = [];

  // filters
  final Set<String> _connector = {};
  final Set<String> _speed = {};
  final Set<String> _availability = {};
  String _search = "";

  // map
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // UI state
  int _currentNavIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _ensureLocationPermission();
    await _setCurrentLocation();
    await _loadStations(); // Use combined loading method
    setState(() => _isLoading = false);
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
                'This app needs location access to show nearby charging stations. Please enable it in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _setCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      setState(() {
        _currentLatLng = const LatLng(22.5726, 88.3639); // Default: Kolkata
      });
    }
  }

  // Combined method to load stations from API with fallback to mock data
  Future<void> _loadStations() async {
    try {
      // Try to load from API first
      final apiStations = await _loadStationsFromApi();
      
      if (apiStations.isNotEmpty) {
        setState(() {
          _all = apiStations;
          _applyFilters();
          _syncMarkers();
        });
      } else {
        // Fallback to mock data
        await _loadMockStations();
      }
    } catch (e) {
      // If API fails, use mock data
      print("API load failed, using mock data: $e");
      await _loadMockStations();
    }
  }

  // Method to load stations from API
  Future<List<EVStation>> _loadStationsFromApi() async {
    try {
      final stations = await _stationApi.getAllStations();
      
      // Convert backend data to EVStation model
      return stations.map<EVStation>((station) {
        return EVStation(
          id: station['id'].toString(),
          name: station['name'] ?? 'Unknown Station',
          lat: (station['latitude'] ?? 0.0).toDouble(),
          lng: (station['longitude'] ?? 0.0).toDouble(),
          address: station['address'] ?? 'No address available',
          connectorType: station['meta']?['connectorType'] ?? 'Type2',
          speed: station['meta']?['speed'] ?? 'Fast',
          availability: station['meta']?['availability'] ?? 'Available',
          rating: (station['meta']?['rating'] ?? 4.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print("Error loading from API: $e");
      return [];
    }
  }

  // Method to load mock stations (existing functionality)
  Future<void> _loadMockStations() async {
    try {
      final items = await _repo.loadMockStations();
      setState(() {
        _all = items;
        _applyFilters();
        _syncMarkers();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load stations'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<EVStation> res = _all.where((s) {
      final matchesConnector =
          _connector.isEmpty || _connector.contains(s.connectorType);
      final matchesSpeed = _speed.isEmpty || _speed.contains(s.speed);
      final matchesAvail =
          _availability.isEmpty || _availability.contains(s.availability);
      final matchesSearch = _search.isEmpty ||
          s.name.toLowerCase().contains(_search.toLowerCase()) ||
          s.address.toLowerCase().contains(_search.toLowerCase());
      return matchesConnector && matchesSpeed && matchesAvail && matchesSearch;
    }).toList();

    setState(() {
      _filtered = res;
    });
  }

  void _syncMarkers() {
    final m = <Marker>{};
    for (final s in _filtered) {
      m.add(Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.lat, s.lng),
        infoWindow: InfoWindow(title: s.name, snippet: s.address),
        onTap: () => _drawRouteTo(LatLng(s.lat, s.lng)),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          s.availability == "Available"
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
      ));
    }
    setState(() {
      _markers
        ..clear()
        ..addAll(m);
    });
  }

  Future<void> _drawRouteTo(LatLng dest) async {
    _polylines.clear();
    if (_currentLatLng == null) return;
    final origin = _currentLatLng!;

    final uri = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&key=$googleMapsApiKey");

    try {
      final resp = await http.get(uri);
      final data = jsonDecode(resp.body);

      if (data["status"] == "OK") {
        final points = data["routes"][0]["overview_polyline"]["points"];
        final decoded = PolylinePoints().decodePolyline(points);
        final coords =
            decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId("route"),
            points: coords,
            color: const Color(0xFF2962FF),
            width: 5,
          ));
        });
      } else {
        await _openInMaps(dest);
      }
    } catch (_) {
      await _openInMaps(dest);
    }
  }

  Future<void> _openInMaps(LatLng dest) async {
    final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=driving");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search stations...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() => _search = "");
                    _applyFilters();
                    _syncMarkers();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _search = value);
          _applyFilters();
          _syncMarkers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EV Charging Locator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50), // Updated to creamy green theme
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: "Filters",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => FilterBottomSheet(
                  connector: _connector,
                  speed: _speed,
                  availability: _availability,
                  onApply: () {
                    Navigator.pop(ctx);
                    _applyFilters();
                    _syncMarkers();
                  },
                  onClear: () {
                    setState(() {
                      _connector.clear();
                      _speed.clear();
                      _availability.clear();
                    });
                    _applyFilters();
                    _syncMarkers();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildSearchBar(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _setCurrentLocation();
          if (_currentLatLng != null) {
            await _map?.animateCamera(
                CameraUpdate.newLatLngZoom(_currentLatLng!, 14));
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      extendBody: true,
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (c) => _map = c,
      initialCameraPosition: CameraPosition(
        target: _currentLatLng ?? const LatLng(22.5726, 88.3639),
        zoom: 12,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: _markers,
      polylines: _polylines,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StationsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.ev_station_outlined),
            selectedIcon: Icon(Icons.ev_station),
            label: 'Stations',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        indicatorColor: const Color(0xFF4CAF50).withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
      ),
    );
  }
}