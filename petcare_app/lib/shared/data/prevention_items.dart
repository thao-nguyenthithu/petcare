import 'package:flutter/widgets.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/utils/song_ngu.dart';

enum PreventionForm { vacXin, uong, nhoGay, khac }

// Một hạng mục phòng bệnh có sẵn
class PreventionItem {
  const PreventionItem({
    required this.ma,
    required this.vi,
    required this.en,
    required this.hinhThuc,
    required this.chuKyDeXuat,
    this.loai,
    this.dinhKy = false,
  });

  // Mã cố định của hạng mục
  final String ma;
  final String vi;
  final String en;
  final PreventionForm hinhThuc;
  final PreventionCycle chuKyDeXuat;
  final PetSpecies? loai;
  final bool dinhKy;
}

// Mã của mục tự nhập
const String maHangMucKhac = 'khac';

// Vắc xin riêng của chó
const _hangMucCho = [
  PreventionItem(
    ma: 'benh5',
    vi: '5 bệnh (Care, Parvo...)',
    en: '5-in-1 vaccine (Distemper, Parvo...)',
    loai: PetSpecies.dog,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.tuan(12),
  ),
  PreventionItem(
    ma: 'benh7',
    vi: '7 bệnh (Care, Parvo...)',
    en: '7-in-1 vaccine (Distemper, Parvo...)',
    loai: PetSpecies.dog,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.tuan(12),
  ),
  PreventionItem(
    ma: 'dai',
    vi: 'Dại',
    en: 'Rabies',
    loai: PetSpecies.dog,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.thang(12),
  ),
];

// Vắc xin riêng của mèo
const _hangMucMeo = [
  PreventionItem(
    ma: 'benh4',
    vi: '4 bệnh (FVRCP + Chlamydia)',
    en: '4-in-1 vaccine (FVRCP + Chlamydia)',
    loai: PetSpecies.cat,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.tuan(12),
  ),
  PreventionItem(
    ma: 'benh3',
    vi: '3 bệnh (FVRCP)',
    en: '3-in-1 vaccine (FVRCP)',
    loai: PetSpecies.cat,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.tuan(12),
  ),
  PreventionItem(
    ma: 'dai',
    vi: 'Dại',
    en: 'Rabies',
    loai: PetSpecies.cat,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.thang(12),
  ),
  PreventionItem(
    ma: 'felv',
    vi: 'Bạch cầu FeLV',
    en: 'Feline leukemia (FeLV)',
    loai: PetSpecies.cat,
    hinhThuc: PreventionForm.vacXin,
    chuKyDeXuat: PreventionCycle.thang(12),
  ),
];

// Hạng mục chó mèo đều cần
const _hangMucChung = [
  PreventionItem(
    ma: 'tayGiun',
    vi: 'Tẩy giun',
    en: 'Deworming',
    hinhThuc: PreventionForm.uong,
    chuKyDeXuat: PreventionCycle.thang(3),
    dinhKy: true,
  ),
  PreventionItem(
    ma: 'veRan',
    vi: 'Phòng ve rận',
    en: 'Flea and tick prevention',
    hinhThuc: PreventionForm.nhoGay,
    chuKyDeXuat: PreventionCycle.thang(1),
    dinhKy: true,
  ),
  PreventionItem(
    ma: 'ghe',
    vi: 'Phòng ghẻ',
    en: 'Mange prevention',
    hinhThuc: PreventionForm.nhoGay,
    chuKyDeXuat: PreventionCycle.thang(1),
    dinhKy: true,
  ),
  PreventionItem(
    ma: maHangMucKhac,
    vi: 'Khác',
    en: 'Other',
    hinhThuc: PreventionForm.khac,
    chuKyDeXuat: PreventionCycle.thang(12),
  ),
];

// Danh mục theo đúng loài bé đã chọn ở bước 1
List<PreventionItem> danhMucHangMuc(PetSpecies loai) => [
  ...(loai == PetSpecies.dog ? _hangMucCho : _hangMucMeo),
  ..._hangMucChung,
];

// Tra nhanh theo mã
final Map<String, PreventionItem> _theoMa = {
  for (final muc in [..._hangMucCho, ..._hangMucMeo, ..._hangMucChung])
    muc.ma: muc,
};

// Tên hạng mục theo ngôn ngữ đang dùng
String tenHangMuc(BuildContext context, String ma) {
  final muc = _theoMa[ma];
  if (muc == null) return ma;
  return tenSongNgu(context, vi: muc.vi, en: muc.en);
}
