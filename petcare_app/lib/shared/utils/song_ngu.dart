import 'package:flutter/widgets.dart';

// Chọn tên giống thú cưng theo ngôn ngữ đang dùng cho các danh mục nghiệp vụ
String tenSongNgu(
  BuildContext context, {
  required String vi,
  required String en,
}) => Localizations.localeOf(context).languageCode == 'en' ? en : vi;
