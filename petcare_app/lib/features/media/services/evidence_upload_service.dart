import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EvidenceUploadService {
  Future<String> uploadSessionPhoto({
    required String bookingId,
    required String phase,
    required File imageFile,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

    final supabase = SupabaseClient(
      const String.fromEnvironment('SUPABASE_URL'),
      const String.fromEnvironment('SUPABASE_ANON_KEY'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    final filename =
        '$bookingId/${phase}_'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '${const Uuid().v4()}.jpg';

    await supabase.storage
        .from('session-photos')
        .upload(
          filename,
          imageFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    return supabase.storage.from('session-photos').getPublicUrl(filename);
  }
}
