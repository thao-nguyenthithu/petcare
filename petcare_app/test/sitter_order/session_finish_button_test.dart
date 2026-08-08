import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_finish_button.dart';

import '../support/don_mau.dart';

Future<void> _bay(WidgetTester tester, WalkingSession phien) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SessionFinishButton(phien: phien)),
    ),
  );
}

bool _bamDuoc(WidgetTester tester) {
  final nut = tester.widget<InkWell>(find.byType(InkWell).first);
  return nut.onTap != null;
}

void main() {
  testWidgets('chưa tới giờ thì nhãn nói mốc giờ mở và nút tắt', (
    tester,
  ) async {
    await _bay(tester, phienMau(gioMoKetThuc: '08:30', metConToiDiemTra: 10));
    expect(find.textContaining('08:30'), findsOneWidget);
    expect(_bamDuoc(tester), isFalse);
  });

  testWidgets('đủ giờ mà chưa có gói GPS thì nói đang xác định vị trí', (
    tester,
  ) async {
    await _bay(tester, phienMau());
    expect(find.textContaining('đang xác định vị trí'), findsOneWidget);
    expect(find.textContaining('còn cách 0'), findsNothing);
    expect(_bamDuoc(tester), isFalse);
  });

  testWidgets('còn xa thì nhãn nói đúng số mét và nút vẫn tắt', (tester) async {
    await _bay(tester, phienMau(metConToiDiemTra: 900));
    expect(find.textContaining('900'), findsOneWidget);
    expect(_bamDuoc(tester), isFalse);
  });

  testWidgets('vào trong bán kính thì nút mở', (tester) async {
    await _bay(tester, phienMau(metConToiDiemTra: 50));
    expect(_bamDuoc(tester), isTrue);
  });

  testWidgets('đơn thiếu toạ độ thì nói không đo được và nút vẫn mở', (
    tester,
  ) async {
    await _bay(tester, phienMau(viTri: null));
    expect(find.textContaining('không đo được vị trí'), findsOneWidget);
    expect(_bamDuoc(tester), isTrue);
  });
}
