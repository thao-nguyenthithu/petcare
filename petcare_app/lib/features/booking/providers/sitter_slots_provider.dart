import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/data/sitter_slots.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';

typedef KhoaLichTrong = ({String sitterId, String petIds});

KhoaLichTrong khoaLichTrong(String? sitterId, Iterable<String> petIds) {
  final ds = petIds.toList()..sort();
  return (sitterId: sitterId ?? '', petIds: ds.join(','));
}

final sitterSlotsProvider = FutureProvider.autoDispose
    .family<SitterSlots, KhoaLichTrong>((ref, khoa) {
      final homNay = homNayVn();
      return BookingsApiService().lichTrong(
        sitterId: khoa.sitterId,
        tu: homNay,
        den: homNay.add(const Duration(days: maxAdvanceDays)),
        petIds: khoa.petIds.isEmpty ? const [] : khoa.petIds.split(','),
      );
    });
