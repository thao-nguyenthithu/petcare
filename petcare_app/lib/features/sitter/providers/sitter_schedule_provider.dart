import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/sitter/data/sitter_availability.dart';
import 'package:petcare_app/features/sitter/providers/sitter_home_provider.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/features/sitter/services/sitter_schedule_api_service.dart';

const int _soNgayNapDau = 35;

// Lịch làm việc của NCC đang đăng nhập
class SitterScheduleNotifier extends AsyncNotifier<SitterSchedule> {
  final _api = SitterScheduleApiService();

  final Set<String> _dangTai = {};

  @override
  Future<SitterSchedule> build() async {
    final tu = dauTuan(homNayVn());
    final den = tu.add(const Duration(days: _soNgayNapDau - 1));
    final khoang = await _api.xemLich(tu, den);
    return const SitterSchedule().gop(tu, den, khoang);
  }

  SitterSchedule get _hienTai => state.value ?? const SitterSchedule();

  Future<void> damBaoKhoang(DateTime tu, DateTime den) async {
    final khoa = '${ngayJson(tu)}_${ngayJson(den)}';
    if (!_dangTai.add(khoa)) return;
    try {
      final cur = state.value ?? await future;
      if (cur.daTaiKhoang(tu, den)) return;
      final khoang = await _api.xemLich(tu, den);
      state = AsyncData(_hienTai.gop(tu, den, khoang));
    } catch (_) {
    } finally {
      _dangTai.remove(khoa);
    }
  }

  Future<void> taiLai(DateTime tu, DateTime den) async {
    state = await AsyncValue.guard(() async {
      final goc = await future;
      if (goc.daTaiKhoang(tu, den)) return goc;
      final khoang = await _api.xemLich(tu, den);
      return goc.gop(tu, den, khoang);
    });
  }

  void _lamMoiTabCongViec() => ref.invalidate(trangChuNguoiChamProvider);

  Future<void> luuGioLamViec(GioLamViec gio) async {
    final daLuu = await _api.luuGioLamViec(gio);
    state = AsyncData(
      _hienTai.copyWith(
        gioBatDau: daLuu.batDau,
        gioKetThuc: daLuu.ketThuc,
        ngayLamViec: daLuu.ngayLamViec,
      ),
    );
    _lamMoiTabCongViec();
  }

  Future<void> luuNgay(DateTime ngay, DayAvailability giaTri) async {
    final daLuu = await _api.luuNgay(ngay, giaTri, _hienTai.soChoToiDa);
    state = AsyncData(
      _hienTai.datNgay(
        ngay,
        daLuu.copyWith(boardingUsed: _hienTai.cuaNgay(ngay).boardingUsed),
      ),
    );
    _lamMoiTabCongViec();
  }

  Future<void> doiSoCho(DateTime ngay, int soChoConNhan) {
    final cuaNgay = _hienTai.cuaNgay(ngay);
    return luuNgay(
      ngay,
      cuaNgay.copyWith(boardingSlots: cuaNgay.boardingUsed + soChoConNhan),
    );
  }

  Future<void> datNghiKhoang(DateTime tu, DateTime den, String? lyDo) async {
    final ngayDaDat = await _api.datNghiKhoang(tu, den, lyDo);
    var moi = _hienTai;
    for (final ngay in ngayDaDat) {
      moi = moi.datNgay(
        ngay,
        DayAvailability(mode: DayMode.nghi, boardingSlots: 0, lyDo: lyDo),
      );
    }
    state = AsyncData(moi);
    _lamMoiTabCongViec();
  }

  Future<void> huyDon(String idDon, String maLyDo, String moTa) async {
    await _api.huyDon(idDon, maLyDo, moTa);
    state = AsyncData(_hienTai.boDon(idDon));
    ref.refreshBookingData(boQua: [sitterScheduleProvider]);
  }
}

final sitterScheduleProvider =
    AsyncNotifierProvider<SitterScheduleNotifier, SitterSchedule>(
      SitterScheduleNotifier.new,
    );
