class ServiceEditResult {
  final ServiceDraft? draft;

  const ServiceEditResult(this.draft);
  const ServiceEditResult.deleted() : draft = null;
}

// Thời lượng cho phép của một lượt dắt (phút)
const walkingDurations = [30, 60, 90];

enum ServiceType { walking, boarding, grooming }

enum PetKind { dog, cat, both }

enum WeightTier { duoi5, tu5den10, tu10den20, tren20 }

// Gói grooming
enum GroomingPackage { bath, bathAndTrim }

class ServiceDraft {
  final ServiceType type;
  final String name;
  final PetKind petKind;

  final int? durationMinutes;

  final int? price;

  final int? capacity;

  final Map<WeightTier, int>? priceByWeight;

  final GroomingPackage? package;

  const ServiceDraft({
    required this.type,
    required this.name,
    required this.petKind,
    this.durationMinutes,
    this.price,
    this.capacity,
    this.priceByWeight,
    this.package,
  });

  int? get lowestWeightPrice {
    final bang = priceByWeight;
    if (bang == null || bang.isEmpty) return null;
    return bang.values.reduce((a, b) => a < b ? a : b);
  }
}
