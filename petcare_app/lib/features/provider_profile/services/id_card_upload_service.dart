import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Upload ảnh CCCD lên bucket
class IdCardUploadService {
  static const _bucket = 'cccd-imgs';
  final _uuid = const Uuid();

  Future<String> upload(Uint8List bytes, {required String mat}) async {
    final storage = Supabase.instance.client.storage.from(_bucket);
    final duongDan = '${_uuid.v4()}_$mat.jpg';
    await storage.uploadBinary(
      duongDan,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    return duongDan;
  }
}
