import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_api.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';

// Bài chủ nuôi đã viết, dựng về đúng dáng của trang Đánh giá của tôi
SitterReview baiCuaToiThanhReview(
  OwnerBookingDetail don,
  BaiDanhGiaApi bai,
  AppLocalizations l10n,
) => SitterReview(
  bookingId: don.id,
  name: don.tenNcc,
  stars: bai.sao,
  service: don.tenDichVu,
  time: bai.luc == null ? '' : ngayThangNam(bai.luc!),
  text: bai.nhanXet,
  anh: bai.anh,
  pets: [
    for (final be in don.pets)
      PetBrief(name: be.name, species: be.species.name, avatar: be.avatar),
  ],
  phanHoi: bai.phanHoi == null
      ? null
      : PhanHoiDanhGia(
          thoiDiem: bai.phanHoiLuc == null ? '' : ngayThangNam(bai.phanHoiLuc!),
          noiDung: bai.phanHoi!,
        ),
);
