import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Khung chung một hàng form nhập thông tin
class InfoRow extends StatelessWidget {
  final String label;
  final Widget content;
  final String? error;
  final VoidCallback? onTap;

  static const double _labelWidth = 150;
  static const double _minHeight = 52;

  const InfoRow({
    super.key,
    required this.label,
    required this.content,
    this.error,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hang = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Row(
          children: [
            if (label.isNotEmpty)
              SizedBox(
                width: _labelWidth,
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Expanded(child: content),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onTap == null) hang else InkWell(onTap: onTap, child: hang),
        Divider(
          height: 1,
          thickness: 1,
          color: error == null ? AppColors.neutral : AppColors.error,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              style: AppTextStyles.captionSm.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

// Hàng gõ chữ
class InfoRowField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const InfoRowField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => validator?.call(controller.text),
      builder: (field) => InfoRow(
        label: label,
        error: field.errorText,
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (_) {
            if (field.hasError) field.validate();
          },
          maxLines: null,
          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption,
            hintMaxLines: 2,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

// Hàng chỉ chọn
class InfoRowPicker extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final String? error;
  final VoidCallback onTap;

  const InfoRowPicker({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daChon = value != null;
    return InfoRow(
      label: label,
      error: error,
      onTap: onTap,
      content: Text(
        value ?? hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: daChon ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
