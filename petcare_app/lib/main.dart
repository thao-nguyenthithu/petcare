import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/locale_provider.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/providers/app_container.dart';
import 'package:petcare_app/core/services/push_refresh.dart';
import 'package:petcare_app/core/services/local_notif_service.dart';
import 'package:petcare_app/core/storage/locale_storage.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/core/theme/app_theme.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  canhBaoApiUrl();
  if (!kIsWeb) FlutterForegroundTask.initCommunicationPort();
  // Bảng chọn ảnh chặn đúng số ảnh cho phép
  batPhotoPickerAndroid();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Tạm thời bỏ qua Firebase: $e');
  }
  String? savedLanguageCode;
  try {
    savedLanguageCode = await const LocaleStorage().readLanguageCode();
  } catch (e) {
    debugPrint('Không đọc được ngôn ngữ đã lưu: $e');
  }
  // Giữ tham chiếu kho provider để guard điều hướng đọc được vai người dùng
  appContainer = ProviderContainer(
    overrides: [savedLanguageCodeProvider.overrideWithValue(savedLanguageCode)],
  );
  await LocalNotifService.instance.khoiTao();
  // Push tới lúc app đang mở phải kéo theo dữ liệu mới
  noiPushVaoLamMoi(appContainer);
  appContainer.read(cauHinhNghiepVuProvider);
  runApp(
    UncontrolledProviderScope(container: appContainer, child: const MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLifecycleListener _vongDoi;

  @override
  void initState() {
    super.initState();
    _vongDoi = AppLifecycleListener(
      onResume: () => lamMoiKhiQuayLai(appContainer),
    );
  }

  @override
  void dispose() {
    _vongDoi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.onLightBackground,
      child: MaterialApp.router(
        title: 'Smart Pet Care',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        locale: ref.watch(localeProvider),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
      ),
    );
  }
}
