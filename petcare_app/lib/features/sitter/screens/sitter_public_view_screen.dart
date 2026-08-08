import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/features/booking/widgets/block_species_sheet.dart';
import 'package:petcare_app/features/booking/widgets/service_pick_sheet.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_area.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_bio.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_calendar.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_hero.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_identity.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_reviews.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_services.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_stats.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/data/booking_args.dart';

// Lề trong hai bên nội dung
const double _le = 18;

// Trang xem hồ sơ NCC; không truyền sitterId là NCC tự xem hồ sơ mình
class SitterPublicViewScreen extends ConsumerWidget {
  const SitterPublicViewScreen({super.key, this.sitterId});

  final String? sitterId;

  bool get _cuaToi => sitterId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hồ sơ của mình
    final AsyncValue<SitterProfile> asyncGoc = _cuaToi
        ? ref
              .watch(sitterMeProvider)
              .whenData(
                (p) => p.copyWith(
                  services: ref.watch(sitterServicesProvider).asData?.value,
                  serviceArea: ref
                      .watch(sitterServiceAreaProvider)
                      .asData
                      ?.value,
                ),
              )
        : ref.watch(sitterPublicProvider(sitterId!));
    final async = asyncGoc;
    final view = async.asData?.value;

    return AnnotatedRegion(
      value: AppSystemUi.onLightBackground,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            AppRefreshIndicator(
              onRefresh: () => _lamMoi(ref),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SitterProfileHero(
                    photos: view?.photos ?? const [],
                    onEdit: _cuaToi
                        ? () => context.push(AppRoutes.sitterProfileEdit)
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 24 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: async.when(
                      data: (v) => _NoiDung(
                        view: v,
                        hienDanhGia: !_cuaToi,
                        sitterId: sitterId,
                      ),
                      loading: () =>
                          const AppSkeletonList(soThe: 4, caoThe: 96),
                      error: (_, _) => _Loi(onThu: () => _lamMoi(ref)),
                    ),
                  ),
                ],
              ),
            ),
            // Nền vùng status bar, cố định không cuộn theo nội dung
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).padding.top,
              child: const IgnorePointer(
                child: ColoredBox(color: AppColors.surface),
              ),
            ),
          ],
        ),
        bottomNavigationBar: (_cuaToi || view == null)
            ? null
            : _ThanhDatLich(
                giaTuThap: _giaThapNhat(view.services),
                onDatLich: () => _datLich(context, ref, view),
              ),
      ),
    );
  }

  // Chặn sớm nếu không dịch vụ nào nhận loài bé đang có
  Future<void> _datLich(
    BuildContext context,
    WidgetRef ref,
    SitterProfile view,
  ) async {
    final services = view.services;
    if (services == null || loaiDangNhan(services).isEmpty) return;

    final pets = ref.read(myPetsProvider).asData?.value ?? const <Pet>[];

    if (khongDichVuNaoHop(pets, services)) {
      final huong = await showBlockSpeciesSheet(
        context,
        tenNcc: view.fullName,
        services: services,
        pets: pets,
      );
      if (!context.mounted || huong == null) return;
      switch (huong) {
        case HuongXuLyLoai.timNguoiCham:
          context.push(AppRoutes.search);
        case HuongXuLyLoai.themHoSoBe:
          context.push(AppRoutes.addPet);
      }
      return;
    }

    final loai = await showServicePickSheet(
      context,
      tenNcc: view.fullName,
      services: services,
      pets: pets,
    );
    if (!context.mounted || loai == null) return;
    // Mỗi loại một trang đặt lịch riêng
    context.push(switch (loai) {
      ServiceType.walking => AppRoutes.bookingWalking,
      ServiceType.boarding => AppRoutes.bookingBoarding,
      ServiceType.grooming => AppRoutes.bookingGrooming,
    }, extra: BookingArgs(sitter: view, loai: loai));
  }

  Future<void> _lamMoi(WidgetRef ref) {
    if (!_cuaToi) {
      return Future.wait([
        ref.refresh(sitterPublicProvider(sitterId!).future),
        ref.read(myPetsProvider.future),
      ]);
    }
    return Future.wait([
      ref.read(sitterMeProvider.future),
      ref.read(sitterServicesProvider.future),
      ref.read(sitterServiceAreaProvider.future),
    ]);
  }
}

int? _giaThapNhat(SitterServices? s) {
  if (s == null) return null;
  final gia = <int>[for (final t in loaiDangNhan(s)) ?s.giaTuCua(t)];
  if (gia.isEmpty) return null;
  return gia.reduce((a, b) => a < b ? a : b);
}

// Toàn bộ nội dung khi có dữ liệu
class _NoiDung extends ConsumerWidget {
  const _NoiDung({
    required this.view,
    required this.hienDanhGia,
    required this.sitterId,
  });

  final SitterProfile view;
  final bool hienDanhGia;
  final String? sitterId;

  // Ngày kín lịch
  LichBanNcc _lichBan(WidgetRef ref) {
    final id = sitterId;
    const rong = (nghi: <DateTime>[], kinDon: <DateTime>[]);
    if (id == null) return rong;
    return ref.watch(ngayKinCuaNccProvider(id)).value ?? rong;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trangDanhGia = sitterId == null
        ? ref.watch(danhGiaVeToiProvider).value
        : ref.watch(danhGiaNguoiChamProvider(sitterId!)).value;
    final danhGia = trangDanhGia?.items ?? const <SitterReview>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Muc(child: SitterProfileIdentity(view: view)),
        const _Ngan(),
        _Muc(child: SitterProfileStats(view: view)),
        const _Ngan(),
        _Muc(child: SitterProfileBio(bio: view.bio ?? '')),
        const _Ngan(),
        _Muc(child: SitterProfileServices(services: view.services)),
        const _Ngan(),
        // Chủ nuôi xem hồ sơ công khai thì không ghim toạ độ nhà NCC trên map
        _Muc(
          child: SitterProfileArea(
            area: view.serviceArea,
            chinhChu: !hienDanhGia,
          ),
        ),
        const _Ngan(),
        _Muc(
          child: SitterProfileCalendar(
            ngayKinDon: _lichBan(ref).kinDon,
            ngayNghi: _lichBan(ref).nghi,
            // Truyền đúng hai danh sách đang hiện để hai màn không nói lệch
            onXemDayDu: () => context.push(
              AppRoutes.sitterAvailability,
              extra: (
                tenNcc: view.fullName,
                ngayKinDon: _lichBan(ref).kinDon,
                ngayNghi: _lichBan(ref).nghi,
              ),
            ),
          ),
        ),
        if (hienDanhGia) ...[
          const _Ngan(),
          _Muc(
            child: SitterProfileReviews(
              tongSo: view.totalReviews,
              reviews: danhGia,
              onXemTatCa: danhGia.isEmpty || trangDanhGia?.thongKe == null
                  ? null
                  : () => context.push(
                      AppRoutes.sitterAllReviews,
                      extra: (
                        tenNcc: view.fullName,
                        thongKe: trangDanhGia!.thongKe!,
                        reviews: danhGia,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Muc extends StatelessWidget {
  const _Muc({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: _le),
    child: child,
  );
}

// Thanh dưới cùng cho chủ nuôi: giá thấp nhất và nút mở luồng đặt lịch
class _ThanhDatLich extends StatelessWidget {
  const _ThanhDatLich({required this.giaTuThap, required this.onDatLich});

  final int? giaTuThap;
  final VoidCallback onDatLich;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_le, 12, _le, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.chiTu, style: AppTextStyles.captionSm),
                    const SizedBox(height: 2),
                    Text(
                      giaTuThap == null ? '—' : '${dinhDangTien(giaTuThap!)}đ',
                      style: AppTextStyles.h2,
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onDatLich,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(140, 52),
                  shape: const StadiumBorder(),
                ),
                child: Text(l10n.datLich),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Báo lỗi
class _Loi extends StatelessWidget {
  const _Loi({required this.onThu});

  final VoidCallback onThu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColors.neutral),
          const SizedBox(height: 12),
          Text(l10n.khongTaiDuocDuLieu, style: AppTextStyles.body),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onThu, child: Text(l10n.thuLai)),
        ],
      ),
    );
  }
}

// Đường kẻ mảnh ngăn mục, kéo hết bề ngang
class _Ngan extends StatelessWidget {
  const _Ngan();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: AppDongKe(),
  );
}
