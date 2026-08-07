import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/sitter_order/data/ai_scan.dart';

// Gọi API lô ảnh check-in và kết quả quét rọ mõm của đơn dắt
class CheckinScanApiService {
  Future<KetQuaLoQuet> guiLo(
    String bookingId, {
    required List<AnhSlot> anh,
    required double lat,
    required double lng,
  }) async {
    final form = FormData.fromMap({
      'slotIndexes': anh.map((a) => a.slotIndex).join(','),
      'lat': lat,
      'lng': lng,
      'photos': [
        for (final a in anh)
          MultipartFile.fromBytes(
            a.bytes,
            filename: 'checkin_${a.slotIndex}.jpg',
          ),
      ],
    });
    final res = await apiClient.post(
      '/sitter/bookings/$bookingId/checkin-batch',
      data: form,
    );
    return KetQuaLoQuet.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<KetQuaLoQuet> ketQuaLo(String bookingId, String batchId) async {
    final res = await apiClient.get(
      '/sitter/bookings/$bookingId/checkin-batch/$batchId',
    );
    return KetQuaLoQuet.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<KetQuaLoQuet> trangThaiQuet(String bookingId) async {
    final res = await apiClient.get('/sitter/bookings/$bookingId/safety-scan');
    return KetQuaLoQuet.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<KetQuaLoQuet> tuXacNhan(String bookingId, int slotIndex) async {
    final res = await apiClient.post(
      '/sitter/bookings/$bookingId/slots/$slotIndex/self-confirm',
    );
    return KetQuaLoQuet.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
