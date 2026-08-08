import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

import '../support/don_mau.dart';

void main() {
  group('Ngưỡng geofence', () {
    test('bám bộ luật mục 5: 200 mét', () {
      expect(metGeofence, 200);
    });
  });

  group('duGio', () {
    test('còn mốc giờ mở thì chưa đủ giờ', () {
      expect(phienMau(gioMoKetThuc: '08:30').duGio, isFalse);
    });

    test('hết mốc giờ mở thì đủ giờ', () {
      expect(phienMau().duGio, isTrue);
    });
  });

  group('duGan', () {
    test('chưa có gói GPS thì chưa đủ gần', () {
      expect(phienMau().duGan, isFalse);
    });

    test('đúng biên 200 m vẫn tính là đủ gần', () {
      expect(phienMau(metConToiDiemTra: 200).duGan, isTrue);
    });

    test('quá biên một mét là chưa đủ gần', () {
      expect(phienMau(metConToiDiemTra: 201).duGan, isFalse);
    });

    test('đứng ngay điểm trả thì đủ gần', () {
      expect(phienMau(metConToiDiemTra: 0).duGan, isTrue);
    });

    // Thiếu toạ độ là lỗi dữ liệu, không được giam tiền phiên
    test('đơn thiếu toạ độ thì bỏ hẳn cửa geofence', () {
      expect(phienMau(viTri: null).duGan, isTrue);
    });

    test('đơn thiếu toạ độ vẫn bỏ cửa dù ở rất xa', () {
      expect(phienMau(viTri: null, metConToiDiemTra: 5000).duGan, isTrue);
    });
  });

  group('moKetThuc', () {
    test('đủ giờ và đủ gần thì mở', () {
      expect(phienMau(metConToiDiemTra: 30).moKetThuc, isTrue);
    });

    test('đủ gần nhưng chưa tới giờ thì không mở', () {
      final phien = phienMau(gioMoKetThuc: '08:30', metConToiDiemTra: 30);
      expect(phien.moKetThuc, isFalse);
    });

    test('đủ giờ nhưng chưa có gói GPS thì không mở', () {
      expect(phienMau().moKetThuc, isFalse);
    });

    test('đơn thiếu toạ độ mà đủ giờ thì vẫn mở được', () {
      expect(phienMau(viTri: null).moKetThuc, isTrue);
    });
  });
}
