import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Băng nhắc chủ nuôi khi có hạng mục phòng bệnh quá hạn
class PetOverdueAlert extends StatelessWidget {
  const PetOverdueAlert({super.key, required this.muc});

  final PreventionRecord muc;

  @override
  Widget build(BuildContext context) {
    final soNgayTre = -(muc.soNgayConLai ?? 0);
    return AppNoteBox(
      kieu: NoteKind.canhBao,
      coNen: true,
      text: context.l10n.canhBaoQuaHanMuc(
        tenCuaHangMuc(context, muc),
        '$soNgayTre',
      ),
    );
  }
}
