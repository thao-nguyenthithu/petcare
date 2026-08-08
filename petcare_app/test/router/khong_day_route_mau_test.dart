import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _router = File('lib/core/router/app_router.dart');

void main() {
  test('phân giải được hằng đường dẫn có tham số', () {
    final tenMau = _hangConMau(_router);
    expect(tenMau, contains('sitterOrderDetail'));
    expect(tenMau, contains('sitterFinishWalk'));
    expect(tenMau, contains('sitterCheckInCamera'));
    expect(tenMau, isNot(contains('sitterHome')));
  });

  test('không nơi nào đẩy hằng đường dẫn còn chứa :id', () {
    final tenMau = _hangConMau(_router);
    final viPham = <String>[];
    for (final tep in _tepDart()) {
      if (tep.path.endsWith('app_router.dart')) continue;
      final noiDung = tep.readAsStringSync();
      for (final ten in tenMau) {
        for (final m in _quyTac(ten).allMatches(noiDung)) {
          viPham.add('${tep.path}:${_dong(noiDung, m.start)} -> $ten');
        }
      }
    }

    expect(
      viPham,
      isEmpty,
      reason:
          'Dùng AppRoutes.<tên>Path(bookingId) thay vì hằng trần:\n'
          '${viPham.join('\n')}',
    );
  });
}

RegExp _quyTac(String ten) => RegExp(
  r'\.(?:push|go|pushReplacement|replace)(?:<[^>]*>)?\(\s*AppRoutes\.' +
      ten +
      r'\s*[),]',
);

int _dong(String noiDung, int viTri) =>
    '\n'.allMatches(noiDung.substring(0, viTri)).length + 1;

List<File> _tepDart() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

Set<String> _hangConMau(File router) {
  final khai = RegExp(r"static const String (\w+) =\s*'([^']*)'");
  final giaTri = <String, String>{};
  final noiDung = router.readAsStringSync().replaceAll('\n', ' ');
  for (final m in khai.allMatches(noiDung)) {
    giaTri[m.group(1)!] = m.group(2)!;
  }
  for (var vong = 0; vong < 5; vong++) {
    giaTri.updateAll((_, v) {
      return v.replaceAllMapped(
        RegExp(r'\$(\w+)'),
        (m) => giaTri[m.group(1)] ?? m.group(0)!,
      );
    });
  }
  return giaTri.entries
      .where((e) => e.value.contains(':id'))
      .map((e) => e.key)
      .toSet();
}
