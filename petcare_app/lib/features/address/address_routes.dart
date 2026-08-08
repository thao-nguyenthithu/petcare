import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/shared/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
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
    builder: (context, state) =>
        LocationPickerScreen(initialCenter: state.extra as LatLng?),
  ),
];
