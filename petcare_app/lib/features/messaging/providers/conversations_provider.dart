import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/messaging/services/messaging_api_service.dart';
import 'package:petcare_app/shared/data/conversation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversations_provider.g.dart';

// Danh sách hội thoại của một vai, hai vai giữ hai bộ nhớ riêng
@Riverpod(keepAlive: true)
class HoiThoaiChuNuoi extends _$HoiThoaiChuNuoi {
  final _service = MessagingApiService();

  @override
  Future<List<Conversation>> build() => _service.danhSach(laChuNuoi: true);

  Future<void> taiLai() async {
    state = await AsyncValue.guard(() => _service.danhSach(laChuNuoi: true));
  }

  Future<void> danhDauDaDoc(String id) async {
    final ds = state.value;
    if (ds != null) state = AsyncData(_daDoc(ds, id));
    await _service.danhDauDaDoc(id);
  }

  void capNhatTinCuoi(String id, String noiDung) {
    final ds = state.value;
    if (ds == null) return;
    state = AsyncData(_tinCuoiCuaToi(ds, id, noiDung));
  }
}

@Riverpod(keepAlive: true)
class HoiThoaiNguoiCham extends _$HoiThoaiNguoiCham {
  final _service = MessagingApiService();

  @override
  Future<List<Conversation>> build() => _service.danhSach(laChuNuoi: false);

  Future<void> taiLai() async {
    state = await AsyncValue.guard(() => _service.danhSach(laChuNuoi: false));
  }

  Future<void> danhDauDaDoc(String id) async {
    final ds = state.value;
    if (ds != null) state = AsyncData(_daDoc(ds, id));
    await _service.danhDauDaDoc(id);
  }

  void capNhatTinCuoi(String id, String noiDung) {
    final ds = state.value;
    if (ds == null) return;
    state = AsyncData(_tinCuoiCuaToi(ds, id, noiDung));
  }
}

List<Conversation> _daDoc(List<Conversation> ds, String id) => [
  for (final c in ds)
    if (c.id == id && c.chuaDoc) c.copyWith(unreadCount: 0) else c,
];

// Hội thoại vừa nhắn nhảy lên đầu
List<Conversation> _tinCuoiCuaToi(
  List<Conversation> ds,
  String id,
  String noiDung,
) {
  final c = ds.where((e) => e.id == id).firstOrNull;
  if (c == null) return ds;
  return [
    c.copyWith(lastMessage: noiDung, lastMessageAt: nowVn(), fromMe: true),
    for (final e in ds)
      if (e.id != id) e,
  ];
}

// Tổng tin chưa đọc cho badge trên tab
@riverpod
int soChuaDocChuNuoi(Ref ref) => ref
    .watch(hoiThoaiChuNuoiProvider)
    .maybeWhen(
      data: (ds) => ds.fold(0, (tong, c) => tong + c.unreadCount),
      orElse: () => 0,
    );

@riverpod
int soChuaDocNguoiCham(Ref ref) => ref
    .watch(hoiThoaiNguoiChamProvider)
    .maybeWhen(
      data: (ds) => ds.fold(0, (tong, c) => tong + c.unreadCount),
      orElse: () => 0,
    );
