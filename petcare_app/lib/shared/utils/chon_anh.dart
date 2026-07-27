import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

// Chọn ảnh từ thư viện máy
final _picker = ImagePicker();

// Chất lượng nén chung cho ảnh hồ sơ
const _chatLuong = 85;

// Một ảnh
Future<Uint8List?> chonMotAnh() async {
  final file = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: _chatLuong,
  );
  return file?.readAsBytes();
}

// Nhiều ảnh
Future<({List<Uint8List> anh, bool du})> chonNhieuAnh(int toiDa) async {
  if (toiDa <= 0) return (anh: const <Uint8List>[], du: true);
  final files = await _picker.pickMultiImage(imageQuality: _chatLuong);
  if (files.isEmpty) return (anh: const <Uint8List>[], du: false);
  final bytes = <Uint8List>[];
  for (final f in files.take(toiDa)) {
    bytes.add(await f.readAsBytes());
  }
  return (anh: bytes, du: files.length > toiDa);
}
