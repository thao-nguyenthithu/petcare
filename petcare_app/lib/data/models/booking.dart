enum BookingStatus {
  pending,
  confirmed,
  awaitingOwnerApproval, // ADR-001: AI fail 3 lần → Owner quyết định
  inProgress,
  completed,
  cancelled,
  disputed,
  resolved,
}

class Booking {
  final String id;
  final BookingStatus status;
  final DateTime updatedAt; // ADR-003: Optimistic Lock token

  const Booking({
    required this.id,
    required this.status,
    required this.updatedAt,
  });
}
