import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Nút Kết thúc, nhãn nói rõ cửa nào đang chặn
class SessionFinishButton extends StatelessWidget {
  const SessionFinishButton({super.key, required this.phien, this.truocKhiMo});

  final WalkingSession phien;

  final Future<void> Function()? truocKhiMo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final met = phien.metConToiDiemTra;
    final String nhan;
    if (!phien.duGio) {
      nhan = l10n.ketThucDichVuMoLuc(phien.don.gioMoKetThuc ?? '');
    } else if (phien.don.viTri == null) {
      nhan = l10n.ketThucDichVuKhongDoDuocViTri;
    } else if (met == null) {
      nhan = l10n.ketThucDichVuDangDoViTri;
    } else if (!phien.duGan) {
      nhan = l10n.ketThucDichVuConCach('$met');
    } else {
      nhan = l10n.ketThucDichVu;
    }
    return AppButton(
      text: nhan,
      height: 50,
      enabled: phien.moKetThuc,
      onTap: () async {
        await truocKhiMo?.call();
        if (context.mounted) {
          context.push(AppRoutes.sitterFinishWalkPath(phien.don.bookingId));
        }
      },
    );
  }
}
