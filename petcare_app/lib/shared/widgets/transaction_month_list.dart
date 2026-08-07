import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/chip_chon.dart';

// Sổ giao dịch nhóm theo tháng
class TransactionMonthList<T> extends StatelessWidget {
  const TransactionMonthList({
    super.key,
    required this.giaoDich,
    required this.mocThoiGian,
    required this.dongTong,
    required this.dungThe,
  });

  final List<T> giaoDich;
  final DateTime Function(T) mocThoiGian;
  final String Function(List<T>) dongTong;
  final Widget Function(T) dungThe;

  List<({DateTime moc, List<T> muc})> get _nhomTheoThang {
    final nhom = <({DateTime moc, List<T> muc})>[];
    for (final g in giaoDich) {
      final t = mocThoiGian(g);
      final moc = DateTime(t.year, t.month);
      if (nhom.isNotEmpty && nhom.last.moc == moc) {
        nhom.last.muc.add(g);
      } else {
        nhom.add((moc: moc, muc: [g]));
      }
    }
    return nhom;
  }

  @override
  Widget build(BuildContext context) {
    final nhom = _nhomTheoThang;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      itemCount: nhom.length,
      itemBuilder: (context, i) => _Thang(
        moc: nhom[i].moc,
        muc: nhom[i].muc,
        dongTong: dongTong,
        dungThe: dungThe,
      ),
    );
  }
}

class _Thang<T> extends StatelessWidget {
  const _Thang({
    required this.moc,
    required this.muc,
    required this.dongTong,
    required this.dungThe,
  });

  final DateTime moc;
  final List<T> muc;
  final String Function(List<T>) dongTong;
  final Widget Function(T) dungThe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.stackGap),
        Text(
          l10n.thangGachNam('${moc.month}', '${moc.year}').toUpperCase(),
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(dongTong(muc), style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.itemGap),
        for (final g in muc) ...[
          dungThe(g),
          if (g != muc.last) const SizedBox(height: AppSpacing.itemGap),
        ],
      ],
    );
  }
}

class TransactionFilterChips<T> extends StatelessWidget {
  const TransactionFilterChips({
    super.key,
    required this.loai,
    required this.dangChon,
    required this.nhan,
    required this.onChon,
  });

  final List<T> loai;
  final T? dangChon;
  final String Function(T) nhan;
  final ValueChanged<T?> onChon;

  static const double _caoHang = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muc = <T?>[null, ...loai];
    return SizedBox(
      height: _caoHang,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.itemGap,
        ),
        itemCount: muc.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (context, i) => ChipChon(
          nhan: muc[i] == null ? l10n.tatCa : nhan(muc[i] as T),
          chon: muc[i] == dangChon,
          onTap: () => onChon(muc[i]),
          canGiua: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          mauChuThuong: AppColors.textSecondary,
        ),
      ),
    );
  }
}
