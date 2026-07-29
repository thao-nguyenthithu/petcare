// Mô hình dịch vụ của một NCC
enum ServiceType { walking, boarding, grooming }

extension ServiceTypeIcon on ServiceType {
  String get iconAsset => switch (this) {
    ServiceType.walking => 'assets/icons/icon_leash.svg',
    ServiceType.boarding => 'assets/icons/paw.svg',
    ServiceType.grooming => 'assets/icons/icon_grooming.svg',
  };
}

enum PetKind { dog, cat, both }

enum WeightTier { duoi5, tu5den10, tu10den20, tren20 }

// Gói grooming: chỉ tắm / tắm và cắt tỉa
enum GroomingPackage { bath, bathAndTrim }

// Thời lượng của một lượt dắt NCC bắt buộc báo giá đủ cả hai mức
const walkingDurations = [30, 60];

PetKind _petKind(Object? s) =>
    PetKind.values.firstWhere((e) => e.name == s, orElse: () => PetKind.both);
int? _toInt(Object? v) => (v as num?)?.toInt();

class WalkingConfig {
  final bool enabled;
  final PetKind petKind;
  final Map<int, int> priceByDuration;
  final int? additionalPetFee;
  final int? maxPets;

  const WalkingConfig({
    this.enabled = false,
    this.petKind = PetKind.dog,
    this.priceByDuration = const {},
    this.additionalPetFee,
    this.maxPets,
  });

  WalkingConfig copyWith({
    bool? enabled,
    PetKind? petKind,
    Map<int, int>? priceByDuration,
    int? additionalPetFee,
    int? maxPets,
  }) => WalkingConfig(
    enabled: enabled ?? this.enabled,
    petKind: petKind ?? this.petKind,
    priceByDuration: priceByDuration ?? this.priceByDuration,
    additionalPetFee: additionalPetFee ?? this.additionalPetFee,
    maxPets: maxPets ?? this.maxPets,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'petKind': petKind.name,
    'priceByDuration': {
      for (final e in priceByDuration.entries) '${e.key}': e.value,
    },
    'additionalPetFee': additionalPetFee,
    'maxPets': maxPets,
  };

  factory WalkingConfig.fromJson(Map<String, dynamic> j) {
    final raw = (j['priceByDuration'] as Map?) ?? const {};
    final bang = <int, int>{};
    for (final phut in walkingDurations) {
      final gia = _toInt(raw['$phut']);
      if (gia != null) bang[phut] = gia;
    }
    return WalkingConfig(
      enabled: j['enabled'] as bool? ?? false,
      petKind: _petKind(j['petKind']),
      priceByDuration: bang,
      additionalPetFee: _toInt(j['additionalPetFee']),
      maxPets: _toInt(j['maxPets']),
    );
  }

  // Đủ giá cho mọi mức thời lượng
  bool get configured =>
      walkingDurations.every((phut) => priceByDuration[phut] != null);

  int? get lowestPrice {
    if (priceByDuration.isEmpty) return null;
    return priceByDuration.values.reduce((a, b) => a < b ? a : b);
  }
}

// Trông giữ tại cơ sở
class BoardingConfig {
  final bool enabled;
  final PetKind petKind;
  final int? pricePerDay;
  final int? capacity;
  final int? additionalPetFee;
  final int? maxPets;

  const BoardingConfig({
    this.enabled = false,
    this.petKind = PetKind.both,
    this.pricePerDay,
    this.capacity,
    this.additionalPetFee,
    this.maxPets,
  });

  BoardingConfig copyWith({
    bool? enabled,
    PetKind? petKind,
    int? pricePerDay,
    int? capacity,
    int? additionalPetFee,
    int? maxPets,
  }) => BoardingConfig(
    enabled: enabled ?? this.enabled,
    petKind: petKind ?? this.petKind,
    pricePerDay: pricePerDay ?? this.pricePerDay,
    capacity: capacity ?? this.capacity,
    additionalPetFee: additionalPetFee ?? this.additionalPetFee,
    maxPets: maxPets ?? this.maxPets,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'petKind': petKind.name,
    'pricePerDay': pricePerDay,
    'capacity': capacity,
    'additionalPetFee': additionalPetFee,
    'maxPets': maxPets,
  };

  factory BoardingConfig.fromJson(Map<String, dynamic> j) => BoardingConfig(
    enabled: j['enabled'] as bool? ?? false,
    petKind: _petKind(j['petKind']),
    pricePerDay: _toInt(j['pricePerDay']),
    capacity: _toInt(j['capacity']),
    additionalPetFee: _toInt(j['additionalPetFee']),
    maxPets: _toInt(j['maxPets']),
  );

  bool get configured => pricePerDay != null && capacity != null;
}

// Grooming tại nhà
class GroomingConfig {
  final bool enabled;
  final PetKind petKind;
  final Map<GroomingPackage, Map<WeightTier, int>> priceByPackage;
  final int? maxPets;

  const GroomingConfig({
    this.enabled = false,
    this.petKind = PetKind.both,
    this.priceByPackage = const {},
    this.maxPets,
  });

  GroomingConfig copyWith({
    bool? enabled,
    PetKind? petKind,
    Map<GroomingPackage, Map<WeightTier, int>>? priceByPackage,
    int? maxPets,
  }) => GroomingConfig(
    enabled: enabled ?? this.enabled,
    petKind: petKind ?? this.petKind,
    priceByPackage: priceByPackage ?? this.priceByPackage,
    maxPets: maxPets ?? this.maxPets,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'petKind': petKind.name,
    'priceByPackage': {
      for (final goi in priceByPackage.entries)
        goi.key.name: {
          for (final muc in goi.value.entries) muc.key.name: muc.value,
        },
    },
    'maxPets': maxPets,
  };

  factory GroomingConfig.fromJson(Map<String, dynamic> j) {
    final raw = (j['priceByPackage'] as Map?) ?? const {};
    final bang = <GroomingPackage, Map<WeightTier, int>>{};
    for (final goi in GroomingPackage.values) {
      final tiers = raw[goi.name] as Map?;
      if (tiers == null) continue;
      final m = <WeightTier, int>{};
      for (final muc in WeightTier.values) {
        final p = _toInt(tiers[muc.name]);
        if (p != null) m[muc] = p;
      }
      if (m.isNotEmpty) bang[goi] = m;
    }
    return GroomingConfig(
      enabled: j['enabled'] as bool? ?? false,
      petKind: _petKind(j['petKind']),
      priceByPackage: bang,
      maxPets: _toInt(j['maxPets']),
    );
  }

  bool get configured => priceByPackage.isNotEmpty;

  int? get lowestPrice {
    final all = priceByPackage.values.expand((b) => b.values);
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a < b ? a : b);
  }
}

// Toàn bộ dịch vụ của một NCC
class SitterServices {
  final WalkingConfig walking;
  final BoardingConfig boarding;
  final GroomingConfig grooming;

  const SitterServices({
    this.walking = const WalkingConfig(),
    this.boarding = const BoardingConfig(),
    this.grooming = const GroomingConfig(),
  });

  bool isEnabled(ServiceType type) => switch (type) {
    ServiceType.walking => walking.enabled,
    ServiceType.boarding => boarding.enabled,
    ServiceType.grooming => grooming.enabled,
  };

  bool isConfigured(ServiceType type) => switch (type) {
    ServiceType.walking => walking.configured,
    ServiceType.boarding => boarding.configured,
    ServiceType.grooming => grooming.configured,
  };

  List<ServiceType> get configuredTypes =>
      ServiceType.values.where(isConfigured).toList();

  bool get hasAny => configuredTypes.isNotEmpty;

  // Có ít nhất một loại đang bật nhận đơn
  bool get anyEnabled => ServiceType.values.any(isEnabled);

  SitterServices copyWith({
    WalkingConfig? walking,
    BoardingConfig? boarding,
    GroomingConfig? grooming,
  }) => SitterServices(
    walking: walking ?? this.walking,
    boarding: boarding ?? this.boarding,
    grooming: grooming ?? this.grooming,
  );

  Map<String, dynamic> toJson() => {
    'walking': walking.toJson(),
    'boarding': boarding.toJson(),
    'grooming': grooming.toJson(),
  };

  factory SitterServices.fromJson(Map<String, dynamic> j) => SitterServices(
    walking: j['walking'] is Map
        ? WalkingConfig.fromJson(Map<String, dynamic>.from(j['walking'] as Map))
        : const WalkingConfig(),
    boarding: j['boarding'] is Map
        ? BoardingConfig.fromJson(
            Map<String, dynamic>.from(j['boarding'] as Map),
          )
        : const BoardingConfig(),
    grooming: j['grooming'] is Map
        ? GroomingConfig.fromJson(
            Map<String, dynamic>.from(j['grooming'] as Map),
          )
        : const GroomingConfig(),
  );
}

enum PricingError {
  trong,
  soBeToiThieu,
  vuotSucChua,
  phuPhiBatBuoc,
  phuPhiThuaBe,
}

// Số bé tối đa mỗi đơn
PricingError? loiSoBeToiDa(int? maxPets, {int? capacity}) {
  if (maxPets == null) return PricingError.trong;
  if (maxPets < 1) return PricingError.soBeToiThieu;
  if (capacity != null && maxPets > capacity) return PricingError.vuotSucChua;
  return null;
}

// Phụ phí mỗi bé thêm
PricingError? loiPhuPhiBeThem(int? phuPhi, int? maxPets) {
  final nhieuBe = maxPets != null && maxPets >= 2;
  if (nhieuBe && phuPhi == null) return PricingError.phuPhiBatBuoc;
  if (phuPhi != null && !nhieuBe) return PricingError.phuPhiThuaBe;
  return null;
}
