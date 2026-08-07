import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

void baoDangPhatTrien(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.chucNangDangPhatTrien)));
}
