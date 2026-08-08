import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';

// Mở Google Maps chỉ đường tới một điểm
Future<void> moChiDuong(BuildContext context, LatLng viTri) async {
  final messenger = ScaffoldMessenger.of(context);
  final loi = context.l10n.khongMoDuocBanDo;
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=${viTri.latitude},${viTri.longitude}',
  );
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(loi)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(loi)));
  }
}
