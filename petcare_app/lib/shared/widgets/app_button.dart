import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

class AppButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final bool outlined;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final double height;
  final bool enabled;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.outlined = false,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = (!widget.enabled || _isLoading)
        ? null
        : (widget.onTapAsync != null ? _runAsyncTap : widget.onTap);
    final label = Text(widget.text);
    final Widget button;
    if (widget.outlined) {
      button = widget.icon == null
          ? OutlinedButton(onPressed: onPressed, child: label)
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(widget.icon, size: 20),
              label: label,
            );
    } else {
      button = widget.icon == null
          ? FilledButton(onPressed: onPressed, child: label)
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(widget.icon, size: 20),
              label: label,
            );
    }
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: button,
    );
  }
}
