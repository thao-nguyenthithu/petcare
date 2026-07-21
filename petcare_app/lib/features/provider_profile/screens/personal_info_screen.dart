import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/features/provider_profile/data/gender.dart';
import 'package:petcare_app/features/provider_profile/data/mock_provider_data.dart';
import 'package:petcare_app/features/provider_profile/widgets/info_row.dart';
import 'package:petcare_app/features/provider_profile/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/utils/date_format.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/choice_sheet.dart';

// Bước 1/3 đăng ký NCC khai thông tin cá nhân theo giấy tờ tùy thân
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _cccdController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _noiCapController = TextEditingController();
  String? _tinhThanh;
  DateTime? _ngaySinh;
  DateTime? _ngayCap;
  Gender? _gioiTinh;

  static const _tuoiToiThieu = 18;

  @override
  void dispose() {
    _hoTenController.dispose();
    _cccdController.dispose();
    _diaChiController.dispose();
    _noiCapController.dispose();
    super.dispose();
  }

  Future<void> _chonNgaySinh() async {
    final homNay = DateTime.now();
    await _chonNgay(
      dangCo: _ngaySinh,
      macDinh: DateTime(homNay.year - 25),
      tuNgay: DateTime(1900),
      denNgay: DateTime(homNay.year - _tuoiToiThieu, homNay.month, homNay.day),
      luuLai: (ngay) => _ngaySinh = ngay,
    );
  }

  Future<void> _chonNgayCap() async {
    final homNay = DateTime.now();
    await _chonNgay(
      dangCo: _ngayCap,
      macDinh: homNay,
      tuNgay: DateTime(2000),
      denNgay: homNay,
      luuLai: (ngay) => _ngayCap = ngay,
    );
  }

  Future<void> _chonNgay({
    required DateTime? dangCo,
    required DateTime macDinh,
    required DateTime tuNgay,
    required DateTime denNgay,
    required void Function(DateTime) luuLai,
  }) async {
    final chon = await showDatePicker(
      context: context,
      initialDate: dangCo ?? macDinh,
      firstDate: tuNgay,
      lastDate: denNgay,
    );
    if (chon == null) return;
    setState(() => luuLai(chon));
  }

  Future<void> _chonGioiTinh() async {
    final l10n = context.l10n;
    final chon = await showChoiceSheet<Gender>(
      context: context,
      items: Gender.values,
      labelOf: (gioi) => _tenGioiTinh(l10n, gioi),
      selected: _gioiTinh,
    );
    if (chon == null) return;
    setState(() => _gioiTinh = chon);
  }

  Future<void> _chonTinhThanh() async {
    final chon = await showChoiceSheet<String>(
      context: context,
      items: MockProviderData.tinhThanh,
      labelOf: (tinh) => tinh,
      selected: _tinhThanh,
    );
    if (chon == null) return;
    setState(() => _tinhThanh = chon);
  }

  String _tenGioiTinh(AppLocalizations l10n, Gender gioi) => switch (gioi) {
    Gender.male => l10n.gioiTinhNam,
    Gender.female => l10n.gioiTinhNu,
    Gender.other => l10n.gioiTinhKhac,
  };

  Widget _hangChon<T>({
    required String label,
    required T? Function() docGiaTri,
    required String Function(T) hienThi,
    required String goiY,
    required Future<void> Function() onChon,
  }) {
    final giaTri = docGiaTri();
    return FormField<T>(
      validator: (_) =>
          docGiaTri() == null ? context.l10n.khongDuocDeTrong : null,
      builder: (field) => InfoRowPicker(
        label: label,
        value: giaTri == null ? null : hienThi(giaTri),
        hint: goiY,
        error: field.errorText,
        onTap: () async {
          await onChon();
          if (field.hasError) field.validate();
        },
      ),
    );
  }

  void _tiepTuc() {
    if (!_formKey.currentState!.validate()) return;
    context.push(AppRoutes.providerIdUpload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: 20),
                  const StepProgressBar(currentStep: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.buocTrenTong('1', '3'),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.thongTinCaNhan, style: AppTextStyles.h1),
                  const SizedBox(height: 12),
                  Text(l10n.nhapDungGiayTo, style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  InfoRowField(
                    label: l10n.hoVaTenThat,
                    hint: l10n.hintHoTenThat,
                    controller: _hoTenController,
                    validator: validators.notEmpty,
                  ),
                  _hangChon<DateTime>(
                    label: l10n.ngaySinh,
                    docGiaTri: () => _ngaySinh,
                    hienThi: dinhDangNgay,
                    goiY: l10n.hintNgayCap,
                    onChon: _chonNgaySinh,
                  ),
                  _hangChon<Gender>(
                    label: l10n.gioiTinh,
                    docGiaTri: () => _gioiTinh,
                    hienThi: (gioi) => _tenGioiTinh(l10n, gioi),
                    goiY: l10n.chonGioiTinh,
                    onChon: _chonGioiTinh,
                  ),
                  InfoRowField(
                    label: l10n.soCccd,
                    hint: l10n.hintCccd,
                    controller: _cccdController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: validators.citizenId,
                  ),
                  _hangChon<String>(
                    label: l10n.tinhThanhPho,
                    docGiaTri: () => _tinhThanh,
                    hienThi: (tinh) => tinh,
                    goiY: l10n.chonTinhThanh,
                    onChon: _chonTinhThanh,
                  ),
                  InfoRowField(
                    label: l10n.diaChiThuongTru,
                    hint: l10n.hintDiaChiChiTiet,
                    controller: _diaChiController,
                    validator: validators.notEmpty,
                  ),
                  InfoRowField(
                    label: l10n.noiCap,
                    hint: l10n.hintNoiCap,
                    controller: _noiCapController,
                    validator: validators.notEmpty,
                  ),
                  _hangChon<DateTime>(
                    label: l10n.ngayCap,
                    docGiaTri: () => _ngayCap,
                    hienThi: dinhDangNgay,
                    goiY: l10n.hintNgayCap,
                    onChon: _chonNgayCap,
                  ),
                  const SizedBox(height: 28),
                  AppButton(text: l10n.tiepTuc, height: 56, onTap: _tiepTuc),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
