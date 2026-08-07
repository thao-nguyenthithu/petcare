import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

// Chọn ảnh từ thư viện máy
final _picker = ImagePicker();

// Chất lượng nén chung cho ảnh hồ sơ
const _chatLuong = 85;
const int canhAnhToiDa = 2576;
const int mbAnhToiDa = 8;
const int _byteToiDa = mbAnhToiDa * 1024 * 1024;
typedef KetQuaMotAnh = ({Uint8List? anh, bool quaNang});
typedef KetQuaNhieuAnh = ({List<Uint8List> anh, bool du, int quaNang});

void batPhotoPickerAndroid() {
  final nen = ImagePickerPlatform.instance;
  if (nen is ImagePickerAndroid) nen.useAndroidPhotoPicker = true;
}

bool _vuaTran(Uint8List bytes) => bytes.lengthInBytes <= _byteToiDa;

Future<KetQuaMotAnh> _docMotAnh(ImageSource nguon) async {
  final file = await _picker.pickImage(
    source: nguon,
    imageQuality: _chatLuong,
    maxWidth: canhAnhToiDa.toDouble(),
    maxHeight: canhAnhToiDa.toDouble(),
  );
  if (file == null) return (anh: null, quaNang: false);
  final bytes = await file.readAsBytes();
  if (!_vuaTran(bytes)) return (anh: null, quaNang: true);
  return (anh: bytes, quaNang: false);
}

Future<KetQuaMotAnh> chonMotAnh() => _docMotAnh(ImageSource.gallery);
Future<KetQuaMotAnh> chupMotAnh() => _docMotAnh(ImageSource.camera);

Future<KetQuaNhieuAnh> chonNhieuAnh(int toiDa) async {
  if (toiDa <= 0) return (anh: const <Uint8List>[], du: true, quaNang: 0);
  if (toiDa == 1) {
    final mot = await chonMotAnh();
    return (
      anh: mot.anh == null ? const <Uint8List>[] : <Uint8List>[mot.anh!],
      du: false,
      quaNang: mot.quaNang ? 1 : 0,
    );
  }
  final files = await _picker.pickMultiImage(
    imageQuality: _chatLuong,
    maxWidth: canhAnhToiDa.toDouble(),
    maxHeight: canhAnhToiDa.toDouble(),
    limit: toiDa,
  );
  if (files.isEmpty) {
    return (anh: const <Uint8List>[], du: false, quaNang: 0);
  }
  final bytes = <Uint8List>[];
  var quaNang = 0;
  for (final f in files.take(toiDa)) {
    final b = await f.readAsBytes();
    if (_vuaTran(b)) {
      bytes.add(b);
    } else {
      quaNang++;
    }
  }
  return (anh: bytes, du: files.length > toiDa, quaNang: quaNang);
}
