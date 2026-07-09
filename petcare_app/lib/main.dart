import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/locale_provider.dart';
import 'package:petcare_app/core/storage/locale_storage.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(
    ProviderScope(
      overrides: [
        savedLanguageCodeProvider.overrideWithValue(savedLanguageCode),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Smart Pet Care',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      ),
    );
  }
}
