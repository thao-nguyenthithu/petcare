enum ServiceType { walking, boarding, grooming }

class ServiceDraft {
  final ServiceType type;
  final String name;
  final String subtitle;

  const ServiceDraft({
    required this.type,
    required this.name,
    required this.subtitle,
  });
}
