import 'package:flutter/widgets.dart';

// Cuộn danh sách
void cuonToi(GlobalKey khoa, {double canTren = 0.05}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = khoa.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: canTren,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });
}
