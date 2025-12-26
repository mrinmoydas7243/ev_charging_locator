
class EVStation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String connectorType; // e.g., CCS2, CHAdeMO, Type2, GB/T
  final String speed; // Slow, Fast, Ultra-Fast
  final String availability; // Available, Occupied
  final double rating; // 0..5

  EVStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.connectorType,
    required this.speed,
    required this.availability,
    required this.rating,
  });

  factory EVStation.fromJson(Map<String, dynamic> json) => EVStation(
        id: json["id"] as String,
        name: json["name"] as String,
        lat: (json["lat"] as num).toDouble(),
        lng: (json["lng"] as num).toDouble(),
        address: json["address"] as String,
        connectorType: json["connectorType"] as String,
        speed: json["speed"] as String,
        availability: json["availability"] as String,
        rating: (json["rating"] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lat": lat,
        "lng": lng,
        "address": address,
        "connectorType": connectorType,
        "speed": speed,
        "availability": availability,
        "rating": rating,
      };
}
