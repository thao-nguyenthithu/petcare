import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_grooming_blocks.dart';
import 'package:petcare_app/features/sitter_order/data/grooming_session.dart';
import 'package:petcare_app/shared/utils/song_ngu.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const _maTinhTrangBe = [
  'hopTacTot',
  'longRoiNhieu',
  'daManDo',
  'taiBan',
  'soMaySay',
  'coVeRan',
];

const _tenTinhTrangBe = {
  'hopTacTot': ('Hợp tác tốt', 'Cooperative'),
  'longRoiNhieu': ('Lông rối nhiều', 'Heavily matted'),
  'daManDo': ('Da mẩn đỏ', 'Skin redness'),
  'taiBan': ('Tai bẩn', 'Dirty ears'),
  'soMaySay': ('Sợ máy sấy', 'Afraid of dryer'),
  'coVeRan': ('Có ve rận', 'Fleas or ticks'),
};

// Màn kết thúc grooming, cũng là chỗ duy nhất tick hạng mục
class SitterFinishGroomingScreen extends ConsumerStatefulWidget {
  const SitterFinishGroomingScreen({super.key, required this.phien});

  final GroomingSession phien;

  @override
  ConsumerState<SitterFinishGroomingScreen> createState() =>
      _SitterFinishGroomingScreenState();
}

class _SitterFinishGroomingScreenState
    extends ConsumerState<SitterFinishGroomingScreen> {
  late final List<List<Uint8List>> _anhSau = [
    for (var i = 0; i < _goiTungBe.length; i++) <Uint8List>[],
  ];

  final Set<String> _tinhTrang = {};
  final _ghiChu = TextEditingController();
  bool _dangGui = false;

  GroomingSession get _phien => widget.phien;
  List<GoiGroomingCuaBe> get _goiTungBe => _phien.goiTungBe;

  int get _soAnhSau => _anhSau.fold(0, (tong, cua) => tong + cua.length);

  bool get _duAnh => _anhSau.every((cua) => cua.length >= soAnhMoiBeToiThieu);

  @override
  void dispose() {
    _ghiChu.dispose();
    super.dispose();
  }

  Future<void> _chup(int viTriBe) async {
    if (_anhSau[viTriBe].length >= soAnhMoiBeToiDa) return;
    final chon = await chupMotAnh();
    if (!mounted) return;
    if (chon.quaNang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
      return;
    }
    final bytes = chon.anh;
    if (bytes == null) return;
    setState(() => _anhSau[viTriBe].add(bytes));
  }

  // Ảnh sau khi làm đi cùng lượt kết thúc
  Future<void> _ketThuc() async {
    final id = _phien.don.bookingId;
    setState(() => _dangGui = true);
    final trangThai = await chayHanhDongLayKetQua(
      context,
      ref,
      id,
      (s) => s.ketThucLayTrangThai(
        id,
        anh: anhMultipart([for (final cua in _anhSau) ...cua], 'after'),
        ghiChu: _ghiChu.text.trim(),
        nhanTinhTrang: _tinhTrang.toList(),
      ),
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (trangThai == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.daGuiXacNhan)));
    dieuHuongSauKetThuc(context, id, trangThai);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = _phien.don;
    final tongHangMuc = _phien.tongHangMuc;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.ketThucDichVu, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonDichVuNBe(
                          don.maDon,
                          don.tenDichVu.split('·').first.trim(),
                          '${don.pets.length}',
                        ),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const FlatDivider(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: SessionStats(
              cot: [
                (
                  so: l10n.nPhut('${don.grooming?.phutDaLam ?? 0}'),
                  nhan: l10n.thoiLuong,
                ),
                (so: '$tongHangMuc/$tongHangMuc', nhan: l10n.hangMucNhan),
                (
                  so: l10n.nAnh('${don.tongAnhTruoc + _soAnhSau}'),
                  nhan: l10n.truocVaSau,
                ),
              ],
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: GroomingTasksToDo(
              goiTungBe: _goiTungBe,
              tieuDe: l10n.cacHangMucCuaDon,
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: _AnhSauKhiLam(
              goiTungBe: _goiTungBe,
              anh: _anhSau,
              onThem: _chup,
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: _ChipTinhTrang(
              dangChon: _tinhTrang,
              onDoi: (ma, chon) => setState(
                () => chon ? _tinhTrang.add(ma) : _tinhTrang.remove(ma),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ghiChuVaKhuyenNghi, style: AppTextStyles.label),
                const SizedBox(height: 14),
                TextField(
                  controller: _ghiChu,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.hintGhiChuKhuyenNghi,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.moTaChuNuoiCoNGioXacNhan('${don.gioGiuTien}'),
                        style: AppTextStyles.captionSm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutralLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
            child: AppButton(
              text: l10n.ketThucVaGuiChoChuNuoi,
              height: 50,
              color: AppColors.accent,
              enabled: _duAnh,
              dangTai: _dangGui,
              onTap: _ketThuc,
            ),
          ),
        ),
      ),
    );
  }
}

// Mỗi bé một hàng để không lẫn tấm của bé này sang bé kia
class _AnhSauKhiLam extends StatelessWidget {
  const _AnhSauKhiLam({
    required this.goiTungBe,
    required this.anh,
    required this.onThem,
  });

  final List<GoiGroomingCuaBe> goiTungBe;
  final List<List<Uint8List>> anh;
  final ValueChanged<int> onThem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daChup = anh.fold(0, (tong, cua) => tong + cua.length);
    final tran = goiTungBe.length * soAnhMoiBeToiDa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.anhSauKhiLamTrenTran('$daChup', '$tran'),
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 14),
        for (final (i, goi) in goiTungBe.indexed) ...[
          if (i != 0) const SizedBox(height: 14),
          Text(goi.be.name, style: AppTextStyles.captionSm),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var o = 0; o < soAnhMoiBeToiDa; o++) ...[
                if (o != 0) const SizedBox(width: 10),
                Expanded(
                  child: o < anh[i].length
                      ? _OAnh(bytes: anh[i][o])
                      : _OThem(onTap: () => onThem(i)),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          l10n.moiBeCanItNhatMotAnhSau('$soAnhMoiBeToiThieu'),
          style: AppTextStyles.captionSm,
        ),
      ],
    );
  }
}

class _OAnh extends StatelessWidget {
  const _OAnh({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.memory(bytes, fit: BoxFit.cover),
      ),
    );
  }
}

class _OThem extends StatelessWidget {
  const _OThem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: AppCard(
        nen: AppColors.background,
        padding: EdgeInsets.zero,
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(context.l10n.them, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ),
    );
  }
}

// Chọn nhiều và không bắt buộc, chỉ để báo lại sau buổi làm
class _ChipTinhTrang extends StatelessWidget {
  const _ChipTinhTrang({required this.dangChon, required this.onDoi});

  final Set<String> dangChon;
  final void Function(String ma, bool chon) onDoi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.tinhTrangBeGhiNhan, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ma in _maTinhTrangBe)
              FilterChip(
                label: Text(
                  tenSongNgu(
                    context,
                    vi: _tenTinhTrangBe[ma]!.$1,
                    en: _tenTinhTrangBe[ma]!.$2,
                  ),
                ),
                selected: dangChon.contains(ma),
                onSelected: (chon) => onDoi(ma, chon),
              ),
          ],
        ),
      ],
    );
  }
}
