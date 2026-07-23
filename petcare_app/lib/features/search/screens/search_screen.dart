import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/search/data/mock_search_data.dart';
import 'package:petcare_app/features/search/widgets/provider_result_tile.dart';
import 'package:petcare_app/features/search/widgets/search_field.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';

// Màn Tìm kiếm với ba trạng thái: chưa gõ, có kết quả, không có kết quả
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Chờ người dùng ngừng gõ rồi mới tìm, tránh gọi API theo từng phím
  static const Duration _doTre = Duration(milliseconds: 300);

  final TextEditingController _controller = TextEditingController();
  Timer? _henGio;
  String _tuKhoa = '';
  MockSearchResult? _ketQua;
  bool _dangTim = false;

  @override
  void dispose() {
    _henGio?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _khiGo(String giaTri) {
    _henGio?.cancel();
    final khoa = giaTri.trim();
    setState(() => _tuKhoa = khoa);
    if (khoa.isEmpty) {
      setState(() {
        _ketQua = null;
        _dangTim = false;
      });
      return;
    }
    setState(() => _dangTim = true);
    _henGio = Timer(_doTre, () => _tim(khoa));
  }

  Future<void> _tim(String khoa) async {
    final ketQua = await MockSearchData.timKiem(khoa);
    // Người dùng có thể đã gõ tiếp trong lúc chờ, bỏ qua kết quả cũ
    if (!mounted || khoa != _tuKhoa) return;
    setState(() {
      _ketQua = ketQua;
      _dangTim = false;
    });
  }

  void _timTheoTuKhoa(String tuKhoa) {
    _controller.text = tuKhoa;
    _khiGo(tuKhoa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchField(
              controller: _controller,
              onChanged: _khiGo,
              onFilter: () => baoDangPhatTrien(context),
            ),
            Expanded(child: _noiDung()),
          ],
        ),
      ),
    );
  }

  // Ba trạng thái đổi hẳn bố cục trang nên if đặt ở màn, không nhét vào con
  Widget _noiDung() {
    if (_tuKhoa.isEmpty) return const _GoiYBanDau();
    if (_dangTim) {
      return const Center(child: CircularProgressIndicator());
    }
    final ketQua = _ketQua;
    if (ketQua == null || ketQua.rong) {
      return _KhongCoKetQua(onChonTuKhoa: _timTheoTuKhoa);
    }
    return _KetQuaTimKiem(ketQua: ketQua, onChonTuKhoa: _timTheoTuKhoa);
  }
}

// Trạng thái chưa gõ: lịch sử, từ khoá phổ biến và danh mục
class _GoiYBanDau extends StatelessWidget {
  const _GoiYBanDau();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.timKiemGanDay, style: AppTextStyles.h3)),
            TextButton(
              onPressed: () => baoDangPhatTrien(context),
              child: Text(
                l10n.xoa,
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.textGap),
        _HangChip(tuKhoas: MockSearchData.ganDay),
        const SizedBox(height: AppSpacing.groupGap),
        Text(l10n.phoBien, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.titleGap),
        _HangChip(tuKhoas: MockSearchData.phoBien),
        const SizedBox(height: AppSpacing.groupGap),
        Text(l10n.danhMuc, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.titleGap),
        const _TheDanhMuc(),
      ],
    );
  }
}

// Trạng thái có kết quả: gợi ý từ khoá rồi tới người chăm
class _KetQuaTimKiem extends StatelessWidget {
  const _KetQuaTimKiem({required this.ketQua, required this.onChonTuKhoa});

  final MockSearchResult ketQua;
  final ValueChanged<String> onChonTuKhoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.labelGap,
              AppSpacing.screenPadding,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                avatar: const Icon(
                  Icons.tune,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                label: Text(l10n.boLoc),
                onPressed: () => baoDangPhatTrien(context),
              ),
            ),
          ),
        ),
        if (ketQua.goiY.isNotEmpty) ...[
          _tieuDe(l10n.goiY),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList.builder(
              itemCount: ketQua.goiY.length,
              itemBuilder: (context, index) => _DongGoiY(
                tuKhoa: ketQua.goiY[index],
                onTap: () => onChonTuKhoa(ketQua.goiY[index]),
              ),
            ),
          ),
        ],
        if (ketQua.nguoiCham.isNotEmpty) ...[
          _tieuDe(l10n.nguoiCham),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList.builder(
              itemCount: ketQua.nguoiCham.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: ProviderResultTile(provider: ketQua.nguoiCham[index]),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.groupGap)),
      ],
    );
  }

  Widget _tieuDe(String chu) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
      ),
      child: Text(chu, style: AppTextStyles.h3),
    ),
  );
}

// Trạng thái không khớp: gợi ý các từ khoá khác cho người dùng thử tiếp
class _KhongCoKetQua extends StatelessWidget {
  const _KhongCoKetQua({required this.onChonTuKhoa});

  final ValueChanged<String> onChonTuKhoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      // 60: đẩy khối rỗng xuống quãng giữa màn, số đo riêng
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        60,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      children: [
        AppEmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.khongTimThayKetQua,
          message: l10n.moTaKhongTimThay,
        ),
        const SizedBox(height: AppSpacing.screenEdgeGap),
        Text(
          l10n.coTheBanQuanTam,
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.titleGap),
        // Dùng Wrap để chip xuống dòng, không bị cụt mép phải như bản Figma
        _HangChip(
          tuKhoas: MockSearchData.danhMuc.map((d) => d.name).toList(),
          canGiua: true,
          onChon: onChonTuKhoa,
        ),
      ],
    );
  }
}

// Nhóm chip từ khoá, tự xuống dòng khi hết chỗ
class _HangChip extends StatelessWidget {
  const _HangChip({required this.tuKhoas, this.canGiua = false, this.onChon});

  final List<String> tuKhoas;
  final bool canGiua;
  final ValueChanged<String>? onChon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.labelGap,
      runSpacing: AppSpacing.labelGap,
      alignment: canGiua ? WrapAlignment.center : WrapAlignment.start,
      children: [
        for (final tuKhoa in tuKhoas)
          ActionChip(
            label: Text(tuKhoa),
            onPressed: () =>
                onChon == null ? baoDangPhatTrien(context) : onChon!(tuKhoa),
          ),
      ],
    );
  }
}

// Một dòng gợi ý từ khoá kèm icon kính lúp
class _DongGoiY extends StatelessWidget {
  const _DongGoiY({required this.tuKhoa, required this.onTap});

  final String tuKhoa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Text(
                tuKhoa,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ba thẻ danh mục có ảnh minh hoạ
class _TheDanhMuc extends StatelessWidget {
  const _TheDanhMuc();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final danhMuc in MockSearchData.danhMuc) ...[
          Expanded(
            child: Material(
              color: AppColors.surface,
              elevation: 2,
              shadowColor: AppColors.shadow,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: InkWell(
                onTap: () => baoDangPhatTrien(context),
                child: Column(
                  children: [
                    Image.asset(
                      danhMuc.image,
                      height: 84,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      child: Text(
                        danhMuc.name,
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (danhMuc != MockSearchData.danhMuc.last)
            const SizedBox(width: AppSpacing.itemGap),
        ],
      ],
    );
  }
}
