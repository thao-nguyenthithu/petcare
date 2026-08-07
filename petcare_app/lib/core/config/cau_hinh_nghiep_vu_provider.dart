import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/core/network/api_client.dart';

// Endpoint công khai, không cần đăng nhập
class CauHinhNghiepVuApi {
  String? _etag;
  CauHinhNghiepVu? _daCache;

  Future<CauHinhNghiepVu?> doc() async {
    final res = await apiClient.get(
      '/config/nghiep-vu',
      options: Options(
        headers: {if (_etag != null) 'If-None-Match': _etag},
        validateStatus: (ma) =>
            ma == 304 || (ma != null && ma >= 200 && ma < 300),
      ),
    );
    if (res.statusCode == 304) return _daCache;
    final than = res.data;
    if (than is! Map) return _daCache;
    _etag = res.headers.value('etag');
    _daCache = CauHinhNghiepVu.fromJson(Map<String, dynamic>.from(than));
    return _daCache;
  }
}

final cauHinhNghiepVuApiProvider = Provider<CauHinhNghiepVuApi>(
  (ref) => CauHinhNghiepVuApi(),
);

// Cấu hình công khai
class CauHinhNghiepVuNotifier extends Notifier<CauHinhNghiepVu> {
  @override
  CauHinhNghiepVu build() {
    Future.microtask(nap);
    return CauHinhNghiepVu.macDinh;
  }

  // Gọi hỏng thì giữ bản đang có, không màn nào được chết vì mất mạng ở đây
  Future<void> nap() async {
    try {
      final moi = await ref.read(cauHinhNghiepVuApiProvider).doc();
      if (moi != null) state = moi;
    } catch (loi) {
      debugPrint('Không đọc được cấu hình nghiệp vụ: $loi');
    }
  }
}

final cauHinhNghiepVuProvider =
    NotifierProvider<CauHinhNghiepVuNotifier, CauHinhNghiepVu>(
      CauHinhNghiepVuNotifier.new,
    );
