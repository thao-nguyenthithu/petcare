import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_map.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';

OwnerBookingDetail donHienHanh(
  BuildContext context,
  WidgetRef ref,
  OwnerBookingDetail banChup,
) {
  final api = ref.watch(bookingDetailProvider(banChup.id)).value;
  if (api == null) return banChup;
  return chiTietTuApi(context, api, ref.watch(cauHinhNghiepVuProvider));
}
