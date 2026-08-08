import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Nhãn đứng trên một trường nhập
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.label);
}

// Ô nhập viền bo góc, nền nhạt — kiểu ô của các màn sửa hồ sơ
class AppTextBox extends StatelessWidget {
  const AppTextBox({
    super.key,
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.duoi,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? duoi;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder vien(Color mau, double rong) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      borderSide: BorderSide(color: mau, width: rong),
    );
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.all(14),
        suffixIcon: duoi,
        enabledBorder: vien(AppColors.neutral, 1),
        focusedBorder: vien(AppColors.primaryColor, 1.5),
        errorBorder: vien(AppColors.error, 1),
        focusedErrorBorder: vien(AppColors.error, 1.5),
      ),
    );
  }
}
