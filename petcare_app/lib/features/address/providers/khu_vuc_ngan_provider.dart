import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/address/services/tra_cuu_dia_chi_service.dart';

// Nhãn khu vực phường, tỉnh
final khuVucNganProvider =
    FutureProvider.family<String?, ({double lat, double lng})>((ref, p) async {
      final r = await TraCuuDiaChiService.traDiaChi(p.lat, p.lng);
      if (r == null) return null;
      final phan = [r.phuong, r.tinh]
          .where((e) => e != null && e.trim().isNotEmpty)
          .map((e) => e!.trim())
          .toList();
      return phan.isEmpty ? null : phan.join(', ');
    });
