class WaypointDto {
  final double lat;
  final double lng;
  final int clientTs; // Timestamp từ app — KHÔNG phải source of truth

  const WaypointDto({
    required this.lat,
    required this.lng,
    required this.clientTs,
  });

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    'clientTs': clientTs,
  };
}
