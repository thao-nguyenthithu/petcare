import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';

// Giờ làm việc mặc định trả về sau khi lưu
typedef GioLamViec = ({String batDau, String ketThuc, Set<int> ngayLamViec});

// Gọi API tab Lịch của NCC
class SitterScheduleApiService {
  Map<String, dynamic> _map(Object? data) =>
      Map<String, dynamic>.from(data as Map);

  // Lịch đơn + giờ rảnh của một khoảng ngày
  Future<KhoangLich> xemLich(DateTime tu, DateTime den) async {
    final res = await apiClient.get(
      '/sitter/schedule',
      queryParameters: {'from': ngayJson(tu), 'to': ngayJson(den)},
    );
    return KhoangLich.fromJson(_map(res.data));
  }

  Future<GioLamViec> luuGioLamViec(GioLamViec gio) async {
    final res = await apiClient.put(
      '/sitter/schedule/working-hours',
      data: {
        'workStart': gio.batDau,
        'workEnd': gio.ketThuc,
        'workDays': gio.ngayLamViec.toList()..sort(),
      },
    );
    final j = _map(res.data);
    return (
      batDau: j['workStart'] as String? ?? gio.batDau,
      ketThuc: j['workEnd'] as String? ?? gio.ketThuc,
      ngayLamViec: {
        for (final t in (j['workDays'] as List?) ?? const [])
          (t as num).toInt(),
      },
    );
  }

  // Chỉnh riêng một ngày, trả về giá trị server đã lưu
  Future<DayAvailability> luuNgay(
    DateTime ngay,
    DayAvailability giaTri,
    int soChoMacDinh,
  ) async {
    final res = await apiClient.put(
      '/sitter/schedule/day',
      data: {
        'date': ngayJson(ngay),
        'mode': giaTri.mode.ma,
        if (giaTri.mode == DayMode.gioRieng) 'start': giaTri.start,
        if (giaTri.mode == DayMode.gioRieng) 'end': giaTri.end,
        'boardingSlots': giaTri.boardingSlots,
        'reason': ?giaTri.lyDo,
      },
    );
    return DayAvailability.fromJson(_map(res.data), soChoMacDinh);
  }

  // Chặn cả một khoảng ngày nghỉ, trả về các ngày đã đặt
  Future<List<DateTime>> datNghiKhoang(
    DateTime tu,
    DateTime den,
    String? lyDo,
  ) async {
    final res = await apiClient.post(
      '/sitter/schedule/block',
      data: {'from': ngayJson(tu), 'to': ngayJson(den), 'reason': ?lyDo},
    );
    final j = _map(res.data);
    return [
      for (final s in (j['days'] as List?) ?? const [])
        ?docNgayJson(s as String),
    ];
  }

  Future<void> huyDon(String idDon, String maLyDo, String moTa) async {
    await apiClient.post(
      '/sitter/schedule/bookings/$idDon/cancel',
      data: {'reason': maLyDo, if (moTa.isNotEmpty) 'note': moTa},
    );
  }
}
