import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

// Chọn ảnh từ thư viện máy
final _picker = ImagePicker();

// Chất lượng nén chung cho ảnh hồ sơ
const _chatLuong = 85;
void batPhotoPickerAndroid() {
  final nen = ImagePickerPlatform.instance;
  if (nen is ImagePickerAndroid) nen.useAndroidPhotoPicker = true;
}

// Một ảnh
Future<Uint8List?> chonMotAnh() async {
  final file = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: _chatLuong,
  );
  return file?.readAsBytes();
}

// Chụp thẳng một ảnh bằng máy ảnh
Future<Uint8List?> chupMotAnh() async {
  final file = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: _chatLuong,
  );
  return file?.readAsBytes();
}

// Nhiều ảnh, chặn số lượng ngay ở bảng chọn của hệ thống bằng `limit`. Vẫn cắt
Future<({List<Uint8List> anh, bool du})> chonNhieuAnh(int toiDa) async {
  if (toiDa <= 0) return (anh: const <Uint8List>[], du: true);
  if (toiDa == 1) {
    final anh = await chonMotAnh();
    return (anh: anh == null ? const <Uint8List>[] : [anh], du: false);
  }
  final files = await _picker.pickMultiImage(
    imageQuality: _chatLuong,
    limit: toiDa,
  );
  if (files.isEmpty) return (anh: const <Uint8List>[], du: false);
  final bytes = <Uint8List>[];
  for (final f in files.take(toiDa)) {
    bytes.add(await f.readAsBytes());
  }
  return (anh: bytes, du: files.length > toiDa);
}
