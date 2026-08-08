import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

const double _khoangHo = 10;

typedef ChoicePill = ({String nhan, bool chon, VoidCallback onTap});

class ChoicePillRow extends StatelessWidget {
  const ChoicePillRow({super.key, required this.items});

  final List<ChoicePill> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (i, e) in items.indexed) ...[
        if (i > 0) const SizedBox(width: _khoangHo),
        Expanded(
          child: AppButton(
            text: e.nhan,
            height: 40,
            radius: AppRadius.radius20,
            outlined: !e.chon,
            onTap: e.onTap,
          ),
        ),
      ],
    ],
  );
}
