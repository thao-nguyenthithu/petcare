import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class FilterPriceRange extends StatefulWidget {
  const FilterPriceRange({
    super.key,
    required this.tieuDe,
    required this.moTa,
    required this.giaTu,
    required this.giaDen,
    required this.onDoi,
  });

  static const int giaSan = 30000;
  static const int giaTran = 500000;

  final String tieuDe;
  final String moTa;
  final int? giaTu;
  final int? giaDen;
  final void Function(int tu, int den) onDoi;

  @override
  State<FilterPriceRange> createState() => _FilterPriceRangeState();
}

class _FilterPriceRangeState extends State<FilterPriceRange> {
  late final TextEditingController _oTu = TextEditingController(
    text: dinhDangTien(widget.giaTu ?? FilterPriceRange.giaSan),
  );
  late final TextEditingController _oDen = TextEditingController(
    text: dinhDangTien(widget.giaDen ?? FilterPriceRange.giaTran),
  );

  int get _tu => widget.giaTu ?? FilterPriceRange.giaSan;
  int get _den => widget.giaDen ?? FilterPriceRange.giaTran;

  @override
  void dispose() {
    _oTu.dispose();
    _oDen.dispose();
    super.dispose();
  }

  void _keo(RangeValues gt) {
    final tu = (gt.start / 5000).round() * 5000;
    final den = (gt.end / 5000).round() * 5000;
    _oTu.text = dinhDangTien(tu);
    _oDen.text = dinhDangTien(den);
    widget.onDoi(tu, den);
  }

  void _goTay() {
    final tu = docSoTien(_oTu.text) ?? FilterPriceRange.giaSan;
    final den = docSoTien(_oDen.text) ?? FilterPriceRange.giaTran;
    final thap = tu <= den ? tu : den;
    final cao = tu <= den ? den : tu;
    widget.onDoi(
      thap.clamp(FilterPriceRange.giaSan, FilterPriceRange.giaTran),
      cao.clamp(FilterPriceRange.giaSan, FilterPriceRange.giaTran),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.textGap),
        Text(widget.moTa, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.itemGap),
        Row(
          children: [
            Text(l10n.giaTien(dinhDangTien(_tu)), style: AppTextStyles.label),
            const Spacer(),
            Text(l10n.giaTien(dinhDangTien(_den)), style: AppTextStyles.label),
          ],
        ),
        RangeSlider(
          values: RangeValues(_tu.toDouble(), _den.toDouble()),
          min: FilterPriceRange.giaSan.toDouble(),
          max: FilterPriceRange.giaTran.toDouble(),
          onChanged: _keo,
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _oTu,
                label: l10n.giaToiThieu,
                hint: dinhDangTien(FilterPriceRange.giaSan),
                height: AppTextField.caoGon,
                keyboardType: TextInputType.number,
                inputFormatters: const [DinhDangTienFormatter()],
                suffixText: l10n.kyHieuDong,
                onChanged: (_) => _goTay(),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: AppTextField(
                controller: _oDen,
                label: l10n.giaToiDa,
                hint: dinhDangTien(FilterPriceRange.giaTran),
                height: AppTextField.caoGon,
                keyboardType: TextInputType.number,
                inputFormatters: const [DinhDangTienFormatter()],
                suffixText: l10n.kyHieuDong,
                onChanged: (_) => _goTay(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
