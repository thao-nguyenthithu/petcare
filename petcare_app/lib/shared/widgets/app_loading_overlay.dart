import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

Future<T> showAppLoading<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator(color: AppColors.surface)),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}
