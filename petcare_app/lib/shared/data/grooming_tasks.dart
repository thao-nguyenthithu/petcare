import 'package:flutter/widgets.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/song_ngu.dart';

// Danh mục hạng mục của buổi tắm và cắt tỉa
class GroomingTask {
  const GroomingTask(this.ma, this.vi, this.en);
  final String ma;
  final String vi;
  final String en;
}

const groomingTasks = <GroomingTask>[
  GroomingTask('tam', 'Tắm', 'Bath'),
  GroomingTask('say', 'Sấy', 'Blow dry'),
  GroomingTask('veSinhTai', 'Vệ sinh tai', 'Ear cleaning'),
  GroomingTask('catMong', 'Cắt móng', 'Nail trim'),
  GroomingTask('catTia', 'Cắt tỉa', 'Haircut'),
];

// Hạng mục mặc định của từng gói
const hangMucMacDinhTheoGoi = <GroomingPackage, List<String>>{
  GroomingPackage.bath: ['tam', 'say', 'veSinhTai'],
  GroomingPackage.bathAndTrim: ['tam', 'say', 'veSinhTai', 'catTia'],
};

// Tên hạng mục theo
String tenHangMucGrooming(BuildContext context, String ma) {
  for (final muc in groomingTasks) {
    if (muc.ma == ma) return tenSongNgu(context, vi: muc.vi, en: muc.en);
  }
  return ma;
}

String dongHangMucGrooming(BuildContext context, List<String> ma) =>
    ma.map((m) => tenHangMucGrooming(context, m)).join(' · ');
