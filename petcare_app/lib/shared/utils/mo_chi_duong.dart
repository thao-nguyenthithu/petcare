import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';

// Mở chỉ đường tới một điểm, thử lần lượt Maps rồi tới trình duyệt
Future<void> moChiDuong(BuildContext context, LatLng viTri) async {
  final messenger = ScaffoldMessenger.of(context);
  final loi = context.l10n.khongMoDuocBanDo;
  final diem = '${viTri.latitude},${viTri.longitude}';
  final web = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$diem',
  );
  // Máy thiếu app bản đồ cũng không được làm tắc lối xuất phát
  final loiDi = <(Uri, LaunchMode)>[
    (
      Uri.parse('google.navigation:q=$diem&mode=d'),
      LaunchMode.externalApplication,
    ),
    (Uri.parse('geo:$diem?q=$diem'), LaunchMode.externalApplication),
    (web, LaunchMode.externalApplication),
    (web, LaunchMode.platformDefault),
  ];
  for (final (uri, cheDo) in loiDi) {
    try {
      if (await launchUrl(uri, mode: cheDo)) return;
    } on Exception {
      continue;
    }
  }
  messenger.showSnackBar(SnackBar(content: Text(loi)));
}
