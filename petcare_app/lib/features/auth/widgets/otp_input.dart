import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.hasError = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _moBanPhim() {
    if (_focusNode.hasFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _moBanPhim,
      child: Stack(
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: (text) {
                setState(() {});
                widget.onChanged?.call(text);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final digit = index < value.length ? value[index] : '';
              final filled = digit.isNotEmpty;
              final active = index == value.length && _focusNode.hasFocus;
              return Container(
                width: 44,
                height: 56,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  border: Border.all(
                    color: (filled || active)
                        ? (widget.hasError
                              ? AppColors.error
                              : AppColors.primaryColor)
                        : AppColors.neutral,
                    width: (filled || active) ? 1.5 : 1,
                  ),
                ),
                child: Text(digit, style: AppTextStyles.h2),
              );
            }),
          ),
        ],
      ),
    );
  }
}
