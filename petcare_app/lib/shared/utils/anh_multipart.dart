import 'dart:typed_data';

import 'package:dio/dio.dart';

List<MultipartFile> anhMultipart(List<Uint8List> anh, String khau) => [
  for (final (i, bytes) in anh.indexed)
    MultipartFile.fromBytes(bytes, filename: '${khau}_$i.jpg'),
];
