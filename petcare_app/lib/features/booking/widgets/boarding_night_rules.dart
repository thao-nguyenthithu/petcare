import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

class BoardingNightRules extends StatefulWidget {
  const BoardingNightRules({super.key, required this.ketLuan});

  final String ketLuan;

  @override
  State<BoardingNightRules> createState() => _BoardingNightRulesState();
}

class _BoardingNightRulesState extends State<BoardingNightRules> {
  bool _mo = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _mo = !_mo),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cachTinhDemVaGioGiuThem,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                _mo
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_right_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (_mo) ...[
          const SizedBox(height: 14),
          AppNoteBox(text: l10n.ghiChuMoiDemToiDa24Gio),
          const SizedBox(height: 10),
          AppNoteBox(text: l10n.ghiChuSoGioDonVe),
          const SizedBox(height: 14),
          const AppDongKe(),
          _Bac(nhan: l10n.lechTrong2Gio, muc: l10n.khongThemPhi),
          const AppDongKe(),
          _Bac(
            nhan: l10n.lechTren2DenGio8,
            muc: l10n.them50MotDem,
            mau: AppColors.honey,
          ),
          const AppDongKe(),
          _Bac(
            nhan: l10n.lechTren8Gio,
            muc: l10n.them100ThanhMotDem,
            mau: AppColors.accent,
          ),
          const AppDongKe(),
        ],
        const SizedBox(height: 12),
        AppNoteBox(text: widget.ketLuan),
      ],
    );
  }
}

class _Bac extends StatelessWidget {
  const _Bac({required this.nhan, required this.muc, this.mau});

  final String nhan;
  final String muc;
  final Color? mau;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(nhan, style: AppTextStyles.label)),
          const SizedBox(width: 12),
          Text(
            muc,
            style: AppTextStyles.label.copyWith(
              color: mau ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
