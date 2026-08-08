import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/notification/data/thong_bao.dart';

typedef TrangThongBao = ({List<ThongBao> items, String? truocTiep});

class NotificationsApiService {
  Future<TrangThongBao> danhSach({String? truoc, VaiNhan? vai}) async {
    final res = await apiClient.get(
      '/notifications',
      queryParameters: {
        'truoc': ?truoc,
        if (vai != null) 'role': maCuaVai(vai),
      },
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    return (
      items: [
        for (final e in data['items'] as List)
          ThongBao.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      truocTiep: data['truocTiep'] as String?,
    );
  }

  Future<int> soChuaDoc() async {
    final res = await apiClient.get('/notifications/unread-count');
    return (Map<String, dynamic>.from(res.data as Map)['soLuong'] as int?) ?? 0;
  }

  Future<void> danhDauDaDoc(String id) =>
      apiClient.patch('/notifications/$id/read');

  Future<void> danhDauDocHet() => apiClient.post('/notifications/read-all');

  // Đăng ký máy này nhận push, locale để backend dựng câu đúng tiếng
  Future<void> luuThietBi(String token, String platform, String locale) =>
      apiClient.post(
        '/notifications/device-token',
        data: {'token': token, 'platform': platform, 'locale': locale},
      );

  Future<void> xoaThietBi(String token) =>
      apiClient.delete('/notifications/device-token/$token');
}
