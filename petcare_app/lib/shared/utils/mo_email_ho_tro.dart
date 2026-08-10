import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';

// Máy không có ứng dụng email thì báo địa chỉ để người dùng tự gửi
Future<String?> moEmailHoTro(
  BuildContext context,
  WidgetRef ref, {
  String? chuDe,
}) async {
  final email = ref.read(cauHinhNghiepVuProvider).emailHoTro;
  if (email == null || email.isEmpty) {
    return context.l10n.chuaCauHinhEmailHoTro;
  }
  final uri = Uri(
    scheme: 'mailto',
    path: email,
    query: chuDe == null ? null : 'subject=${Uri.encodeComponent(chuDe)}',
  );
  final duocMo = await launchUrl(uri);
  if (duocMo) return null;
  if (!context.mounted) return null;
  return context.l10n.guiEmailToiDiaChi(email);
}
