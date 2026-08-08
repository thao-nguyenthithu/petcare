import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/booking/data/booking_created.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/features/booking/providers/sitter_slots_provider.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';

class BookingCreateNotifier extends Notifier<void> {
  final _api = BookingsApiService();

  @override
  void build() {}

  Future<BookingCreated> taoDon(BookingDraft draft) async {
    final don = await _api.taoDon(draft);
    ref.invalidate(
      sitterSlotsProvider(
        khoaLichTrong(draft.sitter.id, [for (final be in draft.pets) be.id]),
      ),
    );
    return don;
  }
}

final bookingCreateProvider = NotifierProvider<BookingCreateNotifier, void>(
  BookingCreateNotifier.new,
);
