enum NhanDiaChi { nha, congTy, khac }

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.tinh,
    required this.phuongXa,
    required this.soNha,
    this.customLabel,
    this.ghiChu,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  final String id;
  final NhanDiaChi label;
  final String tinh;
  final String phuongXa;
  final String soNha;
  final String? customLabel;
  final String? ghiChu;
  final double? lat;
  final double? lng;
  final bool isDefault;

  // Đọc từ JSON của backend
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String,
    label: nhanTuApi(json['label'] as String?),
    tinh: (json['province'] as String?) ?? '',
    phuongXa: (json['ward'] as String?) ?? '',
    soNha: (json['street'] as String?) ?? '',
    customLabel: json['customLabel'] as String?,
    ghiChu: json['note'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    isDefault: (json['isDefault'] as bool?) ?? false,
  );

  // Body gửi lên khi tạo/sửa
  Map<String, dynamic> toJson() => {
    'label': nhanRaApi(label),
    'customLabel': customLabel,
    'province': tinh,
    'ward': phuongXa,
    'street': soNha,
    'note': ghiChu,
    'lat': lat,
    'lng': lng,
  };

  static NhanDiaChi nhanTuApi(String? s) => switch (s) {
    'WORK' => NhanDiaChi.congTy,
    'OTHER' => NhanDiaChi.khac,
    _ => NhanDiaChi.nha,
  };

  static String nhanRaApi(NhanDiaChi l) => switch (l) {
    NhanDiaChi.nha => 'HOME',
    NhanDiaChi.congTy => 'WORK',
    NhanDiaChi.khac => 'OTHER',
  };

  String tenNhan(String nha, String congTy, String khac) => switch (label) {
    NhanDiaChi.nha => nha,
    NhanDiaChi.congTy => congTy,
    NhanDiaChi.khac =>
      (customLabel?.trim().isNotEmpty ?? false) ? customLabel!.trim() : khac,
  };

  String get diaChiDayDu =>
      [soNha, phuongXa, tinh].where((e) => e.trim().isNotEmpty).join(', ');

  SavedAddress copyWith({
    String? id,
    NhanDiaChi? label,
    String? tinh,
    String? phuongXa,
    String? soNha,
    String? customLabel,
    String? ghiChu,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      tinh: tinh ?? this.tinh,
      phuongXa: phuongXa ?? this.phuongXa,
      soNha: soNha ?? this.soNha,
      customLabel: customLabel ?? this.customLabel,
      ghiChu: ghiChu ?? this.ghiChu,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
