import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

const String _album = 'Smart Pet Care';

// Tải cả bộ ảnh về thư viện máy
Future<void> taiAnhVeMay(BuildContext context, List<String> url) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final duong = [for (final u in url) u.trim()]..removeWhere((u) => u.isEmpty);
  if (duong.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.khongCoAnhDeTai)));
    return;
  }
  if (!await Gal.hasAccess(toAlbum: true)) {
    final duocPhep = await Gal.requestAccess(toAlbum: true);
    if (!duocPhep) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.thieuQuyenLuuAnh)));
      return;
    }
  }
  final dio = Dio();
  var xong = 0;
  for (final u in duong) {
    try {
      final res = await dio.get<List<int>>(
        u,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) continue;
      await Gal.putImageBytes(Uint8List.fromList(bytes), album: _album);
      xong++;
    } on Exception {}
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        xong == 0
            ? l10n.taiAnhThatBai
            : l10n.daLuuNAnhVeMay('$xong', '${duong.length}'),
      ),
    ),
  );
}
