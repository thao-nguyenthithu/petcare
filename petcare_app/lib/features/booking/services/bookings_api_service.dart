import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/booking_created.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_api.dart';
import 'package:petcare_app/shared/data/sitter_slots.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Gọi API cụm đặt lịch
class BookingsApiService {
  // Đơn của chính chủ nuôi
  Future<TrangDonCuaToi> danhSachCuaToi({
    required BookingStatus tab,
    PetServiceType? loai,
    String tuKhoa = '',
    int page = 1,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      '/bookings',
      queryParameters: {
        'status': tab.maApi,
        if (loai != null) 'serviceType': loai.maApi,
        if (tuKhoa.trim().isNotEmpty) 'q': tuKhoa.trim(),
        'page': page,
        'limit': limit,
      },
    );
    return TrangDonCuaToi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<ChiTietDonApi> chiTiet(String id) async {
    final res = await apiClient.get('/bookings/$id');
    return ChiTietDonApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // Huỷ đơn
  Future<ChiTietDonApi> huyDon(
    String id, {
    required String lyDo,
    String moTa = '',
  }) async {
    final res = await apiClient.post(
      '/bookings/$id/cancel',
      data: {'reason': lyDo, if (moTa.trim().isNotEmpty) 'note': moTa.trim()},
    );
    return ChiTietDonApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> xuatPhat(String id) async {
    await apiClient.post('/bookings/$id/depart');
  }

  Future<ChiTietDonApi> xacNhanHoanThanh(String id) async {
    final res = await apiClient.post('/bookings/$id/confirm');
    return ChiTietDonApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> moKhieuNai(
    String id, {
    required String moTa,
    List<MultipartFile> anh = const [],
  }) async {
    final form = FormData.fromMap({'description': moTa, 'photos': anh});
    await apiClient.post('/bookings/$id/dispute', data: form);
  }

  Future<ChiTietDonApi> ketThucSom(
    String id, {
    required String ngayTra,
    required String gioTra,
  }) async {
    final res = await apiClient.post(
      '/bookings/$id/end-early',
      data: {'endDate': ngayTra, 'endTime': gioTra},
    );
    return ChiTietDonApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SitterSlots> lichTrong({
    required String sitterId,
    required DateTime tu,
    required DateTime den,
    List<String> petIds = const [],
  }) async {
    final res = await apiClient.get(
      '/sitters/$sitterId/slots',
      queryParameters: {
        'from': ngayJson(tu),
        'to': ngayJson(den),
        if (petIds.isNotEmpty) 'petIds': petIds.join(','),
      },
    );
    return SitterSlots.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<BookingCreated> taoDon(BookingDraft draft) async {
    final res = await apiClient.post('/bookings', data: _body(draft));
    return BookingCreated.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Map<String, dynamic> _body(BookingDraft draft) {
    final ghiChu = draft.ghiChu.trim();
    return {
      'sitterId': draft.sitter.id,
      'serviceType': draft.loai.name,
      'petIds': [for (final be in draft.pets) be.id],
      'addressId': draft.diaChiChon!.id,
      'startDate': ngayJson(draft.ngay!),
      'startTime': draft.gio!.nhan,
      if (draft.loai == ServiceType.boarding) ...{
        'endDate': ngayJson(draft.ngayTra!),
        'endTime': draft.gioTra!.nhan,
      },
      if (draft.loai == ServiceType.walking) ...{
        'durationMinutes': draft.phutMotLuot,
        'gearCommitted': draft.camKetDungCu,
      },
      if (draft.loai == ServiceType.grooming)
        'packages': [
          for (final be in draft.pets)
            if (draft.goiTheoBe[be.id] != null)
              {'petId': be.id, 'packageCode': draft.goiTheoBe[be.id]!.name},
        ],
      if (ghiChu.isNotEmpty) 'note': ghiChu,
    };
  }
}
