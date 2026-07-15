import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final double height;
  final bool enabled;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.onTapAsync,
    this.height = 54,
    this.enabled = true,
  }) : assert(
         (onTap == null) != (onTapAsync == null),
         'Truyền đúng một trong hai: onTap hoặc onTapAsync',
       );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isLoading = false;

  Future<void> _runAsyncTap() async {
    setState(() => _isLoading = true);
    try {
      await showAppLoading(context, widget.onTapAsync!);
    } finally {
      // Trang có thể đã bị đóng trong lúc chờ — chỉ setState khi còn sống
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: FilledButton(
        onPressed: (!widget.enabled || _isLoading)
            ? null
            : (widget.onTapAsync != null ? _runAsyncTap : widget.onTap),
        child: Text(widget.text),
      ),
    );
  }
}
