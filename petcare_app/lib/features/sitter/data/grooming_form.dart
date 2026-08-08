import 'package:flutter/widgets.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

const groomingHintGia = {
  WeightTier.duoi5: '150.000',
  WeightTier.tu5den10: '220.000',
  WeightTier.tu10den20: '300.000',
  WeightTier.tren20: '400.000',
};

// Lỗi của một mức cân đang bật
enum GroomingTierError { trong, giaKhongHopLe, thoiLuong }

class GroomingForm {
  final Set<GroomingPackage> goiNhan;
  final Map<GroomingPackage, Set<WeightTier>> mucNhan;

  final Map<GroomingPackage, Map<WeightTier, TextEditingController>> gia = {
    for (final goi in GroomingPackage.values)
      goi: {for (final muc in WeightTier.values) muc: TextEditingController()},
  };
  final Map<GroomingPackage, Map<WeightTier, TextEditingController>> phut = {
    for (final goi in GroomingPackage.values)
      goi: {for (final muc in WeightTier.values) muc: TextEditingController()},
  };
  final Map<GroomingPackage, Map<WeightTier, FocusNode>> oGia = {
    for (final goi in GroomingPackage.values)
      goi: {for (final muc in WeightTier.values) muc: FocusNode()},
  };
  final Map<GroomingPackage, Map<WeightTier, FocusNode>> oPhut = {
    for (final goi in GroomingPackage.values)
      goi: {for (final muc in WeightTier.values) muc: FocusNode()},
  };

  GroomingForm.from(GroomingConfig config)
    : goiNhan = config.priceByPackage.keys.toSet(),
      mucNhan = {
        for (final goi in GroomingPackage.values)
          goi: config.priceByPackage[goi]?.keys.toSet() ?? <WeightTier>{},
      } {
    for (final goi in GroomingPackage.values) {
      for (final muc in WeightTier.values) {
        final tien = config.priceByPackage[goi]?[muc];
        if (tien != null) gia[goi]![muc]!.text = dinhDangTien(tien);
        final so = config.phutCua(goi, muc);
        if (so != null) phut[goi]![muc]!.text = '$so';
      }
    }
  }

  List<TextEditingController> get _moiO => [
    for (final bang in [gia, phut])
      for (final theoGoi in bang.values) ...theoGoi.values,
  ];

  void addListener(VoidCallback lang) {
    for (final o in _moiO) {
      o.addListener(lang);
    }
  }

  void dispose() {
    for (final o in _moiO) {
      o.dispose();
    }
    for (final bang in [oGia, oPhut]) {
      for (final theoGoi in bang.values) {
        for (final node in theoGoi.values) {
          node.dispose();
        }
      }
    }
  }

  // Bật/tắt một gói
  void doiGoi(GroomingPackage goi) {
    if (!goiNhan.remove(goi)) goiNhan.add(goi);
  }

  void doiMuc(GroomingPackage goi, WeightTier muc, bool bat) {
    final ds = mucNhan[goi] ?? <WeightTier>{};
    if (bat) {
      ds.add(muc);
    } else {
      ds.remove(muc);
      gia[goi]![muc]!.clear();
      phut[goi]![muc]!.clear();
    }
    mucNhan[goi] = ds;
  }

  bool nhanMuc(GroomingPackage goi, WeightTier muc) =>
      mucNhan[goi]?.contains(muc) ?? false;

  GroomingTierError? loiMuc(GroomingPackage goi, WeightTier muc) {
    if (!goiNhan.contains(goi) || !nhanMuc(goi, muc)) return null;
    final tien = docSoTien(gia[goi]![muc]!.text);
    final so = int.tryParse(phut[goi]![muc]!.text);
    if (tien == null || so == null) return GroomingTierError.trong;
    if (tien <= 0) return GroomingTierError.giaKhongHopLe;
    if (so < groomingPhutToiThieu ||
        so > groomingPhutToiDa ||
        so % groomingPhutBuoc != 0) {
      return GroomingTierError.thoiLuong;
    }
    return null;
  }

  bool thieuMuc(GroomingPackage goi) =>
      goiNhan.contains(goi) && (mucNhan[goi]?.isEmpty ?? true);

  bool get hopLe {
    if (goiNhan.isEmpty) return false;
    for (final goi in goiNhan) {
      if (thieuMuc(goi)) return false;
      for (final muc in WeightTier.values) {
        if (loiMuc(goi, muc) != null) return false;
      }
    }
    return true;
  }

  // Ô lỗi đầu tiên theo đúng thứ tự hiển thị
  FocusNode? get oLoiDauTien {
    for (final goi in GroomingPackage.values) {
      if (!goiNhan.contains(goi)) continue;
      for (final muc in WeightTier.values) {
        final loi = loiMuc(goi, muc);
        if (loi == null) continue;
        final thieuGia = docSoTien(gia[goi]![muc]!.text) == null;
        return thieuGia || loi == GroomingTierError.giaKhongHopLe
            ? oGia[goi]![muc]!
            : oPhut[goi]![muc]!;
      }
    }
    return null;
  }

  // Chỉ lấy gói đang bán và mức đang nhận
  GroomingConfig toConfig({required PetKind petKind, required int? maxPets}) {
    final bangGia = <GroomingPackage, Map<WeightTier, int>>{};
    final bangPhut = <GroomingPackage, Map<WeightTier, int>>{};
    for (final goi in GroomingPackage.values) {
      if (!goiNhan.contains(goi)) continue;
      final g = <WeightTier, int>{};
      final p = <WeightTier, int>{};
      for (final muc in WeightTier.values) {
        if (!nhanMuc(goi, muc)) continue;
        final tien = docSoTien(gia[goi]![muc]!.text);
        final so = int.tryParse(phut[goi]![muc]!.text);
        if (tien == null || so == null) continue;
        g[muc] = tien;
        p[muc] = so;
      }
      if (g.isEmpty) continue;
      bangGia[goi] = g;
      bangPhut[goi] = p;
    }
    return GroomingConfig(
      enabled: true,
      petKind: petKind,
      priceByPackage: bangGia,
      durationByPackage: bangPhut,
      maxPets: maxPets,
    );
  }
}
