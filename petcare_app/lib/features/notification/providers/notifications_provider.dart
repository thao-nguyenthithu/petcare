import 'package:petcare_app/features/notification/data/thong_bao.dart';
import 'package:petcare_app/features/notification/services/notifications_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

// Hộp thông báo, giữ cả hai vai trong một danh sách rồi lọc ở tầng hiển thị
@Riverpod(keepAlive: true)
class ThongBaoCuaToi extends _$ThongBaoCuaToi {
  final _service = NotificationsApiService();
  String? _truocTiep;
  bool _dangTaiThem = false;

  @override
  Future<List<ThongBao>> build() async {
    final trang = await _service.danhSach();
    _truocTiep = trang.truocTiep;
    return trang.items;
  }

  bool get conTrangSau => _truocTiep != null;

  Future<void> taiLai() async {
    state = await AsyncValue.guard(() async {
      final trang = await _service.danhSach();
      _truocTiep = trang.truocTiep;
      return trang.items;
    });
  }

  Future<void> taiThem() async {
    final truoc = _truocTiep;
    if (truoc == null || _dangTaiThem) return;
    _dangTaiThem = true;
    try {
      final trang = await _service.danhSach(truoc: truoc);
      _truocTiep = trang.truocTiep;
      state = AsyncData([...?state.value, ...trang.items]);
    } finally {
      _dangTaiThem = false;
    }
  }

  Future<void> danhDauDaDoc(String id) async {
    _doiTaiCho((n) => n.id == id ? n.copyWith(daDoc: true) : n);
    try {
      await _service.danhDauDaDoc(id);
    } catch (_) {}
  }

  Future<void> danhDauDocHet() async {
    _doiTaiCho((n) => n.daDoc ? n : n.copyWith(daDoc: true));
    try {
      await _service.danhDauDocHet();
    } catch (_) {
      // như trên
    }
  }

  void _doiTaiCho(ThongBao Function(ThongBao) doi) {
    final ds = state.value;
    if (ds == null) return;
    state = AsyncData([for (final n in ds) doi(n)]);
  }
}

@riverpod
int soThongBaoChuaDoc(Ref ref, VaiNhan? vai) {
  final ds = ref.watch(thongBaoCuaToiProvider).value ?? const <ThongBao>[];
  return ds.theoVai(vai).where((n) => !n.daDoc).length;
}
