import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

class AppButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final bool outlined;
  final bool flat;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final double height;
  final bool enabled;
  final Color? color;
  // Bỏ trống thì radius14
  final double? radius;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.outlined = false,
    this.flat = false,
    this.onTap,
    this.onTapAsync,
    this.height = 54,
    this.enabled = true,
    this.color,
    this.radius,
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
    final shape = widget.radius == null
        ? null
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius!),
          );
    final ButtonStyle? style = (widget.color == null && shape == null)
        ? null
        : widget.flat
        ? TextButton.styleFrom(foregroundColor: widget.color, shape: shape)
        : widget.outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: widget.color,
            side: widget.color == null
                ? null
                : BorderSide(color: widget.color!),
            shape: shape,
          )
        : FilledButton.styleFrom(backgroundColor: widget.color, shape: shape);
    final Widget button;
    if (widget.flat) {
      button = widget.icon == null
          ? TextButton(onPressed: onPressed, style: style, child: label)
          : TextButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(widget.icon, size: 20),
              label: label,
            );
    } else if (widget.outlined) {
      button = widget.icon == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: label)
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(widget.icon, size: 20),
              label: label,
            );
    } else {
      button = widget.icon == null
          ? FilledButton(onPressed: onPressed, style: style, child: label)
          : FilledButton.icon(
              onPressed: onPressed,
              style: style,
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
