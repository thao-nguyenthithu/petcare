import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/text_normalize.dart';

// Gợi ý từ khoá dựng
class SearchSuggestions {
  SearchSuggestions._();

  static const int _toiDa = 8;

  static List<String> choBan(AppLocalizations l10n, List<Pet> pets) {
    final ds = <String>[for (final loai in LoaiDichVu.values) loai.ten(l10n)];
    for (final be in pets.take(3)) {
      final loaiBe = tenLoai(l10n, be.species);
      ds.add(
        '${LoaiDichVu.trongGiu.ten(l10n)} $loaiBe '
        '${l10n.soKgCanNang(canNangGon(be.weightKg))}',
      );
    }
    return ds.take(_toiDa).toList();
  }

  // Gợi ý trong lúc gõ
  static List<String> theoTuKhoa(
    AppLocalizations l10n,
    String tuKhoa,
    List<String> lichSu,
  ) {
    final khoa = boDau(tuKhoa.trim().toLowerCase());
    if (khoa.isEmpty) return const [];
    final nguon = <String>[
      ...lichSu,
      for (final loai in LoaiDichVu.values) loai.ten(l10n),
    ];
    final daCo = <String>{};
    return nguon
        .where((e) => boDau(e.toLowerCase()).contains(khoa))
        .where(daCo.add)
        .take(_toiDa)
        .toList();
  }
}
