import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool isRequired;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final double height;
  final Color? fillColor;
  final String? suffixText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.fieldKey,
    this.height = 52,
    this.fillColor,
    this.suffixText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final paddingDoc = (widget.height - 22) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              text: widget.label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.caption,
            filled: true,
            fillColor: widget.fillColor ?? AppColors.background,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: paddingDoc,
            ),
            enabledBorder: _vien(AppColors.neutral),
            focusedBorder: _vien(AppColors.primaryColor),
            errorBorder: _vien(AppColors.error),
            focusedErrorBorder: _vien(AppColors.error),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
            suffixText: widget.suffixText,
            suffixStyle: AppTextStyles.caption,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _vien(Color mau) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.radius14),
    borderSide: BorderSide(color: mau, width: 1.5),
  );
}
