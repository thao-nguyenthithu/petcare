import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/features/provider_profile/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

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
  final _ngayCapController = TextEditingController();
  String? _tinhThanh;

  static const _dsTinhThanh = [
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Hải Phòng',
    'Cần Thơ',
  ];

  @override
  void dispose() {
    _hoTenController.dispose();
    _cccdController.dispose();
    _diaChiController.dispose();
    _noiCapController.dispose();
    _ngayCapController.dispose();
    super.dispose();
  }

  Future<void> _chonNgayCap() async {
    final homNay = DateTime.now();
    final chon = await showDatePicker(
      context: context,
      initialDate: homNay,
      firstDate: DateTime(2000),
      lastDate: homNay,
    );
    if (chon == null) return;
    _ngayCapController.text =
        '${chon.day.toString().padLeft(2, '0')}/'
        '${chon.month.toString().padLeft(2, '0')}/${chon.year}';
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
                  const StepProgressBar(currentStep: 2),
                  const SizedBox(height: 20),
                  Text(
                    l10n.buocTrenTong('2', '4'),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.thongTinCaNhan, style: AppTextStyles.h1),
                  const SizedBox(height: 12),
                  Text(l10n.nhapDungGiayTo, style: AppTextStyles.caption),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: l10n.hoVaTenThat,
                    hint: l10n.hintHoTenThat,
                    controller: _hoTenController,
                    height: 48,
                    validator: validators.notEmpty,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l10n.soCccd,
                    hint: l10n.hintCccd,
                    controller: _cccdController,
                    height: 48,
                    keyboardType: TextInputType.number,
                    validator: validators.citizenId,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.diaChiThuongTru,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _tinhThanh,
                    items: [
                      for (final tinh in _dsTinhThanh)
                        DropdownMenuItem(
                          value: tinh,
                          child: Text(
                            tinh,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _tinhThanh = value),
                    validator: (value) =>
                        value == null ? l10n.khongDuocDeTrong : null,
                    hint: Text(
                      l10n.chonTinhThanh,
                      style: AppTextStyles.caption,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      enabledBorder: _vien(AppColors.neutral),
                      focusedBorder: _vien(AppColors.primaryColor),
                      errorBorder: _vien(AppColors.error),
                      focusedErrorBorder: _vien(AppColors.error),
                      errorStyle: AppTextStyles.captionSm.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: '',
                    hint: l10n.hintDiaChiChiTiet,
                    controller: _diaChiController,
                    height: 48,
                    validator: validators.notEmpty,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.noiCap,
                          hint: l10n.hintNoiCap,
                          controller: _noiCapController,
                          height: 48,
                          validator: validators.notEmpty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        // Ô ngày chỉ đọc: chạm là mở lịch chọn ngày chuẩn
                        child: GestureDetector(
                          onTap: _chonNgayCap,
                          child: AbsorbPointer(
                            child: AppTextField(
                              label: l10n.ngayCap,
                              hint: l10n.hintNgayCap,
                              controller: _ngayCapController,
                              height: 48,
                              validator: validators.notEmpty,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  OutlineInputBorder _vien(Color mau) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.radius14),
    borderSide: BorderSide(color: mau, width: 1.5),
  );
}
