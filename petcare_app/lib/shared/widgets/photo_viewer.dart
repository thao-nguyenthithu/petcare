import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/widgets/photo_item.dart';

export 'package:petcare_app/shared/widgets/photo_item.dart';

// Bảng màu nền tối riêng của trình xem ảnh
const _nen = Color(0xFF141A18);
const _nenThanhHanhDong = Color(0xFF1B2321);
const _nenNutHanhDong = Color(0xFF242E2B);
const _nenAnh = Color(0xFF2A3330);
const _chuPhu = Color(0xFFC8D2CE);
const _chuNut = Color(0xFFDFE6E3);
const _chuNguyHiem = Color(0xFFFF8D66);

// Mức phóng to tối đa
const double _phongToiDa = 5;
const double _phongChamHai = 2.5;

// Một nút ở thanh hành động dưới đáy trình xem
class PhotoViewerAction {
  const PhotoViewerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.nguyHiem = false,
    this.tatKhi,
  });

  final IconData icon;
  final String label;

  final Future<bool> Function(int viTri) onTap;

  final bool nguyHiem;

  // Vô hiệu hoá nút ở một số vị trí
  final bool Function(int viTri)? tatKhi;
}

// Xem ảnh toàn màn hình
Future<void> showPhotoViewer(
  BuildContext context, {
  required List<PhotoItem> anh,
  int viTri = 0,
  String? phuDe,
  String Function(int viTri)? phuDeCua,
  List<PhotoViewerAction> hanhDong = const [],
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PhotoViewerScreen(
        anh: anh,
        viTri: viTri,
        phuDe: phuDe,
        phuDeCua: phuDeCua,
        hanhDong: hanhDong,
      ),
    ),
  );
}

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.anh,
    this.viTri = 0,
    this.phuDe,
    this.phuDeCua,
    this.hanhDong = const [],
  });

  final List<PhotoItem> anh;
  final int viTri;

  // Phụ đề chung cho cả tập ảnh
  final String? phuDe;

  // Phụ đề riêng của từng ảnh
  final String Function(int viTri)? phuDeCua;
  final List<PhotoViewerAction> hanhDong;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final _controller = PageController(initialPage: widget.viTri);
  late int _hienTai = widget.viTri;

  // Đang phóng to thì khoá vuốt đổi ảnh
  bool _dangPhongTo = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _chonAnh(int i) {
    setState(() => _hienTai = i);
    _controller.jumpToPage(i);
  }

  Future<void> _chay(PhotoViewerAction hanhDong) async {
    final dong = await hanhDong.onTap(_hienTai);
    if (dong && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final nhieuAnh = widget.anh.length > 1;
    return Scaffold(
      backgroundColor: _nen,
      body: SafeArea(
        child: Column(
          children: [
            _ThanhTren(
              tieuDe: '${_hienTai + 1} / ${widget.anh.length}',
              phuDe: widget.phuDeCua?.call(_hienTai) ?? widget.phuDe,
              ngayThem: widget.anh[_hienTai].ngayThem,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.anh.length,
                physics: _dangPhongTo
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                onPageChanged: (i) => setState(() {
                  _hienTai = i;
                  _dangPhongTo = false;
                }),
                itemBuilder: (_, i) => _TrangAnh(
                  // Đổi trang thì dựng lại trang cũ để mức phóng trở về 1
                  key: ValueKey(i),
                  anh: widget.anh[i],
                  onDoiMucPhong: (phongTo) {
                    if (phongTo != _dangPhongTo) {
                      setState(() => _dangPhongTo = phongTo);
                    }
                  },
                ),
              ),
            ),
            if (nhieuAnh) ...[
              const SizedBox(height: AppSpacing.itemGap),
              _ChamChiSo(tong: widget.anh.length, hienTai: _hienTai),
              const SizedBox(height: AppSpacing.itemGap),
              _DaiAnhNho(anh: widget.anh, hienTai: _hienTai, onChon: _chonAnh),
            ],
            const SizedBox(height: AppSpacing.itemGap),
            if (widget.hanhDong.isNotEmpty)
              _ThanhHanhDong(
                hanhDong: widget.hanhDong,
                viTri: _hienTai,
                onChay: _chay,
              ),
          ],
        ),
      ),
    );
  }
}

// Phóng to, kéo để xem phần ảnh
class _TrangAnh extends StatefulWidget {
  const _TrangAnh({super.key, required this.anh, required this.onDoiMucPhong});

  final PhotoItem anh;
  final ValueChanged<bool> onDoiMucPhong;

  @override
  State<_TrangAnh> createState() => _TrangAnhState();
}

class _TrangAnhState extends State<_TrangAnh>
    with SingleTickerProviderStateMixin {
  final _bienDoi = TransformationController();
  late final _chayMuot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() => _bienDoi.value = _buocPhong!.value);
  Animation<Matrix4>? _buocPhong;

  TapDownDetails? _diemCham;

  @override
  void initState() {
    super.initState();
    _bienDoi.addListener(_bao);
  }

  @override
  void dispose() {
    _bienDoi.removeListener(_bao);
    _chayMuot.dispose();
    _bienDoi.dispose();
    super.dispose();
  }

  void _bao() =>
      widget.onDoiMucPhong(_bienDoi.value.getMaxScaleOnAxis() > 1.01);

  void _chamHaiLan() {
    final dangPhongTo = _bienDoi.value.getMaxScaleOnAxis() > 1.01;
    final diem = _diemCham?.localPosition ?? Offset.zero;
    final dich = dangPhongTo
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -diem.dx * (_phongChamHai - 1),
              -diem.dy * (_phongChamHai - 1),
              0,
              1,
            )
            ..scaleByDouble(_phongChamHai, _phongChamHai, _phongChamHai, 1));
    _buocPhong = Matrix4Tween(
      begin: _bienDoi.value,
      end: dich,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_chayMuot));
    _chayMuot.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _diemCham = d,
      onDoubleTap: _chamHaiLan,
      child: InteractiveViewer(
        transformationController: _bienDoi,
        minScale: 1,
        maxScale: _phongToiDa,
        child: Center(
          child: PhotoThumb(anh: widget.anh, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ThanhTren extends StatelessWidget {
  const _ThanhTren({required this.tieuDe, this.phuDe, this.ngayThem});

  final String tieuDe;
  final String? phuDe;

  // Ngày đăng ảnh
  final DateTime? ngayThem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.labelGap),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  tieuDe,
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
                // Phụ đề gồm tên hạng mục và ngày
                if (phuDe != null)
                  Text(
                    phuDe!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSm.copyWith(color: _chuPhu),
                  ),
                // Ảnh nào cũng phải cho biết đăng từ bao giờ
                if (ngayThem case final ngay?)
                  Text(
                    context.l10n.themNgay(ngayThangNam(ngay)),
                    style: AppTextStyles.captionSm.copyWith(
                      color: _chuPhu.withValues(alpha: .75),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ChamChiSo extends StatelessWidget {
  const _ChamChiSo({required this.tong, required this.hienTai});

  final int tong;
  final int hienTai;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < tong; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: i == hienTai ? 7 : 5,
            height: i == hienTai ? 7 : 5,
            decoration: BoxDecoration(
              color: i == hienTai
                  ? Colors.white
                  : _chuPhu.withValues(alpha: .5),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

class _DaiAnhNho extends StatelessWidget {
  const _DaiAnhNho({
    required this.anh,
    required this.hienTai,
    required this.onChon,
  });

  final List<PhotoItem> anh;
  final int hienTai;
  final ValueChanged<int> onChon;

  static const double _canh = 56;
  static const double _boGoc = AppRadius.radius14;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _canh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: anh.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (_, i) => Material(
          color: _nenAnh,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: i == hienTai
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(_boGoc),
          ),
          child: InkWell(
            onTap: () => onChon(i),
            child: SizedBox(
              width: _canh,
              height: _canh,
              child: PhotoThumb(anh: anh[i], canh: _canh),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThanhHanhDong extends StatelessWidget {
  const _ThanhHanhDong({
    required this.hanhDong,
    required this.viTri,
    required this.onChay,
  });

  final List<PhotoViewerAction> hanhDong;
  final int viTri;
  final ValueChanged<PhotoViewerAction> onChay;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      width: double.infinity,
      color: _nenThanhHanhDong,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap + mq.viewPadding.bottom,
      ),
      child: Row(
        children: [
          for (final muc in hanhDong) ...[
            if (muc != hanhDong.first)
              const SizedBox(width: AppSpacing.labelGap),
            Expanded(
              child: _Nut(
                muc: muc,
                onTap: muc.tatKhi?.call(viTri) == true
                    ? null
                    : () => onChay(muc),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Nut extends StatelessWidget {
  const _Nut({required this.muc, required this.onTap});

  final PhotoViewerAction muc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mauGoc = muc.nguyHiem ? _chuNguyHiem : _chuNut;
    final mau = onTap == null ? mauGoc.withValues(alpha: .4) : mauGoc;
    return Material(
      color: _nenNutHanhDong,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
          child: Column(
            children: [
              Icon(muc.icon, size: 20, color: mau),
              const SizedBox(height: 7),
              Text(
                muc.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm.copyWith(
                  color: mau,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
