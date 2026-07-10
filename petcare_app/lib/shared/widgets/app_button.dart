import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(onPressed: onTap, child: Text(text)),
    );
  }
}
