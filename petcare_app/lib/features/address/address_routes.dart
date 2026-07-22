import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/address/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/address/data/saved_address.dart';
import 'package:petcare_app/features/address/screens/add_address_screen.dart';
import 'package:petcare_app/features/address/screens/address_list_screen.dart';
import 'package:petcare_app/features/address/screens/location_picker_screen.dart';

// Route cụm địa chỉ: danh sách, thêm/sửa, chọn vị trí trên bản đồ
final addressRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.addresses,
    builder: (context, state) => const AddressListScreen(),
  ),
  GoRoute(
    path: AppRoutes.addAddress,
    // extra: SavedAddress khi sửa, KetQuaViTri khi thêm mới từ bản đồ
    builder: (context, state) {
      final extra = state.extra;
      return AddAddressScreen(
        diaChiSua: extra is SavedAddress ? extra : null,
        viTriMoi: extra is KetQuaViTri ? extra : null,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.locationPicker,
    // extra: LatLng tâm ban đầu khi bấm chỉnh từ map xem trước
    builder: (context, state) =>
        LocationPickerScreen(initialCenter: state.extra as LatLng?),
  ),
];
