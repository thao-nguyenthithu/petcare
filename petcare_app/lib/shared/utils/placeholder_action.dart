import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

// TẠM (dùng chung mọi feature): báo "chức năng đang phát triển" ở các điểm chạm
// chưa có màn đích. Khi màn đích làm xong thì thay lời gọi bằng
// context.push(...) tương ứng; hết chỗ gọi thì xoá file này.
void baoDangPhatTrien(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.chucNangDangPhatTrien)));
}
