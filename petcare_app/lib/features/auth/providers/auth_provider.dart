import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/token_storage.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<bool> build() async {
    final storage = TokenStorageService();
    return storage.hasToken();
  }
}
