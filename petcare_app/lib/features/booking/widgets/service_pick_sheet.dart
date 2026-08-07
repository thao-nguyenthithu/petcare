import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';

typedef _Dong = ({
  ServiceType loai,
  String phu,
  String gia,
  bool chonDuoc,
  String? lyDo,
});

// Sheet chọn dịch vụ trước khi vào trang đặt lịch
Future<ServiceType?> showServicePickSheet(
  BuildContext context, {
  required String tenNcc,
  required SitterServices services,
  required List<Pet> pets,
}) {
  return showModalBottomSheet<ServiceType>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        _ServicePickSheet(tenNcc: tenNcc, services: services, pets: pets),
  );
}

class _ServicePickSheet extends StatefulWidget {
  const _ServicePickSheet({
    required this.tenNcc,
    required this.services,
    required this.pets,
  });

  final String tenNcc;
  final SitterServices services;
  final List<Pet> pets;

  @override
  State<_ServicePickSheet> createState() => _ServicePickSheetState();
}

class _ServicePickSheetState extends State<_ServicePickSheet> {
  ServiceType? _chon;

  @override
  void initState() {
    super.initState();
    for (final t in loaiDangNhan(widget.services)) {
      if (_chonDuoc(t)) {
        _chon = t;
        break;
      }
    }
  }

  List<_Dong> _dsDong(BuildContext context) {
    final s = widget.services;
    return [
      for (final t in loaiDangNhan(s))
        (
          loai: t,
          phu: _moTaLoai(context, s, t),
          gia: _giaTu(context, s, t),
          chonDuoc: _chonDuoc(t),
          lyDo: _chonDuoc(t) ? null : _lyDoMo(context, s, t, widget.pets),
        ),
    ];
  }

  // Chưa có bé nào đặt được thì vẫn cho vào trang đặt lịch để thêm hồ sơ bé
  bool _chonDuoc(ServiceType t) =>
      widget.pets.isEmpty ||
      beDatDuoc(widget.pets, widget.services, t).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final dong = _dsDong(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.blockGap + mq.viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.datDichVuVoi(widget.tenNcc), style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.nccNhanNDichVu(widget.tenNcc, '${dong.length}'),
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            const AppDongKe(),
            const SizedBox(height: AppSpacing.stackGap),
            for (final d in dong) ...[
              ButtonSelect(
                selected: d.chonDuoc && _chon == d.loai,
                title: serviceTypeName(context, d.loai),
                titleColor: d.chonDuoc
                    ? (_chon == d.loai ? AppColors.primaryColor : null)
                    : AppColors.neutral,
                subtitle: d.chonDuoc ? d.phu : d.lyDo,
                subtitleMaxLines: 2,
                subtitleColor: d.chonDuoc ? null : AppColors.neutral,
                trailing: Text(
                  d.gia,
                  style: AppTextStyles.label.copyWith(
                    color: d.chonDuoc
                        ? AppColors.textPrimary
                        : AppColors.neutral,
                  ),
                ),
                onTap: d.chonDuoc ? () => setState(() => _chon = d.loai) : null,
              ),
              const SizedBox(height: AppSpacing.itemGap),
            ],
            const SizedBox(height: AppSpacing.textGap),
            AppNoteBox(text: l10n.ghiChuXemKyDichVu),
            const SizedBox(height: AppSpacing.stackGap),
            AppButton(
              text: l10n.tiepTuc,
              enabled: _chon != null,
              onTap: () => Navigator.pop(context, _chon),
            ),
          ],
        ),
      ),
    );
  }
}

// Dòng mô tả loài, thời lượng hoặc cách tính giá
String _moTaLoai(BuildContext c, SitterServices s, ServiceType t) {
  final l10n = c.l10n;
  final kind = loaiNhanCua(s, t);
  final loai = kind == PetKind.both ? l10n.choVaMeoDai : petKindLabel(c, kind);
  final soBe = soBeToiDaCua(s, t);
  return switch (t) {
    ServiceType.walking => [
      loai,
      l10n.nPhut(walkingDurations.join('/')),
      l10n.toiDaNBe('${soBe ?? 1}'),
    ].join(' · '),
    ServiceType.boarding => [
      loai,
      l10n.taiCoSo,
      l10n.toiDaNBe('${soBe ?? 1}'),
    ].join(' · '),
    ServiceType.grooming => [
      loai,
      l10n.taiNhaBan,
      l10n.theoCanNang,
    ].join(' · '),
  };
}

String _giaTu(BuildContext c, SitterServices s, ServiceType t) =>
    c.l10n.tuGiaTien(dinhDangTien(s.giaTuCua(t) ?? 0));

String _lyDoMo(
  BuildContext c,
  SitterServices s,
  ServiceType t,
  List<Pet> pets,
) {
  if (beHopLoai(pets, s, t).isNotEmpty) return c.l10n.vuotMucCanNcc;
  final loaiBe = pets.first.species == PetSpecies.dog ? c.l10n.cho : c.l10n.meo;
  return c.l10n.lyDoChiNhanLoai(
    petKindLabel(c, loaiNhanCua(s, t)).toLowerCase(),
    loaiBe.toLowerCase(),
  );
}
