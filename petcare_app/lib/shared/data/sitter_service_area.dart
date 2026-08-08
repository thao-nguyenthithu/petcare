import 'package:latlong2/latlong.dart';

const minServiceRadiusKm = 1;
const defaultServiceRadiusKm = 5;

// Địa điểm khu vực phục vụ của NCC
class SitterServiceArea {
  final String? address;
  final String? khuVuc;
  final double? lat;
  final double? lng;
  final String? addressNote;
  final int radiusKm;

  const SitterServiceArea({
    this.address,
    this.khuVuc,
    this.lat,
    this.lng,
    this.addressNote,
    this.radiusKm = defaultServiceRadiusKm,
  });

  LatLng? get viTri => (lat != null && lng != null) ? LatLng(lat!, lng!) : null;

  // Đã đặt khu vực phục vụ
  bool get daDat => lat != null && lng != null;

  SitterServiceArea copyWith({
    String? address,
    String? khuVuc,
    double? lat,
    double? lng,
    String? addressNote,
    int? radiusKm,
  }) => SitterServiceArea(
    address: address ?? this.address,
    khuVuc: khuVuc ?? this.khuVuc,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    addressNote: addressNote ?? this.addressNote,
    radiusKm: radiusKm ?? this.radiusKm,
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'lat': lat,
    'lng': lng,
    'addressNote': addressNote,
    'radiusKm': radiusKm,
  };

  factory SitterServiceArea.fromJson(Map<String, dynamic> j) =>
      SitterServiceArea(
        address: j['address'] as String?,
        khuVuc: j['area'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        addressNote: j['addressNote'] as String?,
        radiusKm: (j['radiusKm'] as num?)?.toInt() ?? defaultServiceRadiusKm,
      );
}
