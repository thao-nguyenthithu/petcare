import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @tenUngDung.
  ///
  /// In vi, this message translates to:
  /// **'Smart Pet Care'**
  String get tenUngDung;

  /// No description provided for @xinChao.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào'**
  String get xinChao;

  /// No description provided for @doiLaiTrongCaiDat.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể thay đổi lại trong Cài đặt'**
  String get doiLaiTrongCaiDat;

  /// No description provided for @tiepTuc.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get tiepTuc;

  /// No description provided for @boQua.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get boQua;

  /// No description provided for @chaoMungDen.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến'**
  String get chaoMungDen;

  /// No description provided for @thuCungVui.
  ///
  /// In vi, this message translates to:
  /// **'Thú cưng vui, sống vui mỗi ngày'**
  String get thuCungVui;

  /// No description provided for @ketNoiNguoiChamSoc.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối với người chăm sóc thú cưng uy tín, ngay gần bạn'**
  String get ketNoiNguoiChamSoc;

  /// No description provided for @chamSoc.
  ///
  /// In vi, this message translates to:
  /// **'Chăm sóc'**
  String get chamSoc;

  /// No description provided for @tinCay.
  ///
  /// In vi, this message translates to:
  /// **'tin cậy'**
  String get tinCay;

  /// No description provided for @minhBachAnhGps.
  ///
  /// In vi, this message translates to:
  /// **'Minh bạch bằng ảnh & GPS realtime'**
  String get minhBachAnhGps;

  /// No description provided for @nguoiCungCapXacMinh.
  ///
  /// In vi, this message translates to:
  /// **'Người cung cấp được xác minh, minh bạch bằng ảnh và GPS thời gian thực'**
  String get nguoiCungCapXacMinh;

  /// No description provided for @theoDoi.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi'**
  String get theoDoi;

  /// No description provided for @sucKhoe.
  ///
  /// In vi, this message translates to:
  /// **'sức khỏe'**
  String get sucKhoe;

  /// No description provided for @hoSoNhacLich.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ & nhắc lịch thú cưng'**
  String get hoSoNhacLich;

  /// No description provided for @lichSuDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử dịch vụ, nhắc lịch và hồ sơ sức khỏe luôn trong tầm tay'**
  String get lichSuDichVu;

  /// No description provided for @batDauNgay.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ngay'**
  String get batDauNgay;

  /// No description provided for @dangNhap.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get dangNhap;

  /// No description provided for @chaoMungQuayLai.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn quay trở lại!'**
  String get chaoMungQuayLai;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @nhapEmail.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email của bạn'**
  String get nhapEmail;

  /// No description provided for @matKhau.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get matKhau;

  /// No description provided for @nhapMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get nhapMatKhau;

  /// No description provided for @quenMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get quenMatKhau;

  /// No description provided for @hoac.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get hoac;

  /// No description provided for @google.
  ///
  /// In vi, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In vi, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @chuaCoTaiKhoan.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get chuaCoTaiKhoan;

  /// No description provided for @dangKyNgay.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get dangKyNgay;

  /// No description provided for @dangKyTaiKhoan.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tài khoản'**
  String get dangKyTaiKhoan;

  /// No description provided for @thamGiaCongDong.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia cộng đồng yêu thú cưng'**
  String get thamGiaCongDong;

  /// No description provided for @hoVaTen.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get hoVaTen;

  /// No description provided for @nhapHoVaTen.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên của bạn'**
  String get nhapHoVaTen;

  /// No description provided for @soDienThoai.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get soDienThoai;

  /// No description provided for @nhapSoDienThoai.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại'**
  String get nhapSoDienThoai;

  /// No description provided for @toiThieu6KyTu.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 6 ký tự'**
  String get toiThieu6KyTu;

  /// No description provided for @xacNhanMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get xacNhanMatKhau;

  /// No description provided for @nhapLaiMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get nhapLaiMatKhau;

  /// No description provided for @dangKy.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get dangKy;

  /// No description provided for @daCoTaiKhoan.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get daCoTaiKhoan;

  /// No description provided for @vuiLongNhapEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email'**
  String get vuiLongNhapEmail;

  /// No description provided for @emailKhongHopLe.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get emailKhongHopLe;

  /// No description provided for @vuiLongNhapMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get vuiLongNhapMatKhau;

  /// No description provided for @matKhauKhongKhop.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu nhập lại không khớp'**
  String get matKhauKhongKhop;

  /// No description provided for @vuiLongNhapHoTen.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên'**
  String get vuiLongNhapHoTen;

  /// No description provided for @vuiLongNhapSoDienThoai.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số điện thoại'**
  String get vuiLongNhapSoDienThoai;

  /// No description provided for @soDienThoaiKhongHopLe.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get soDienThoaiKhongHopLe;

  /// No description provided for @chucNangDangPhatTrien.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng đang phát triển'**
  String get chucNangDangPhatTrien;

  /// No description provided for @xacMinhEmail.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh email'**
  String get xacMinhEmail;

  /// No description provided for @nhapMa6So.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã 6 số vừa gửi tới email:'**
  String get nhapMa6So;

  /// No description provided for @nhapMa6SoCuaBan.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã 6 số vừa gửi tới email của bạn'**
  String get nhapMa6SoCuaBan;

  /// No description provided for @guiLaiMaSau.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau {time}'**
  String guiLaiMaSau(String time);

  /// No description provided for @khongNhanDuocMa.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận được mã?'**
  String get khongNhanDuocMa;

  /// No description provided for @guiLaiSauGiay.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại sau {seconds}s'**
  String guiLaiSauGiay(String seconds);

  /// No description provided for @guiLaiMa.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get guiLaiMa;

  /// No description provided for @xacNhan.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get xacNhan;

  /// No description provided for @doiEmail.
  ///
  /// In vi, this message translates to:
  /// **'Đổi email'**
  String get doiEmail;

  /// No description provided for @nhapEmailMoiNhanMa.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email mới để nhận lại mã xác minh.'**
  String get nhapEmailMoiNhanMa;

  /// No description provided for @nhapEmailDaDangKy.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email đã đăng ký, chúng tôi sẽ gửi mã xác minh để đặt lại mật khẩu.'**
  String get nhapEmailDaDangKy;

  /// No description provided for @guiMaXacMinh.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã xác minh'**
  String get guiMaXacMinh;

  /// No description provided for @quayLaiDangNhap.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get quayLaiDangNhap;

  /// No description provided for @xacMinhOtp.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh OTP'**
  String get xacMinhOtp;

  /// No description provided for @datLaiMatKhau.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get datLaiMatKhau;

  /// No description provided for @taoMatKhauMoi.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mật khẩu mới cho tài khoản của bạn.'**
  String get taoMatKhauMoi;

  /// No description provided for @matKhauMoi.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get matKhauMoi;

  /// No description provided for @dungChuHoaThuongSo.
  ///
  /// In vi, this message translates to:
  /// **'Dùng chữ hoa, chữ thường và số để mạnh hơn.'**
  String get dungChuHoaThuongSo;

  /// No description provided for @vuiLongNhapDu6So.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đủ 6 số'**
  String get vuiLongNhapDu6So;

  /// No description provided for @datLaiMatKhauThanhCong.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu thành công, hãy đăng nhập'**
  String get datLaiMatKhauThanhCong;

  /// No description provided for @xacThucEmailThanhCong.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực email thành công!'**
  String get xacThucEmailThanhCong;

  /// No description provided for @taiKhoanSanSang.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của bạn đã sẵn sàng. Bạn có thể đăng nhập và sử dụng app với vai trò Chủ nuôi ngay bây giờ.'**
  String get taiKhoanSanSang;

  /// No description provided for @moiDangKyNcc.
  ///
  /// In vi, this message translates to:
  /// **'Muốn cung cấp dịch vụ và kiếm thêm thu nhập? Sau khi đăng nhập, bạn có thể đăng ký trở thành Người cung cấp dịch vụ trong mục Tài khoản.'**
  String get moiDangKyNcc;

  /// No description provided for @buocTrenTong.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current} / {total}'**
  String buocTrenTong(String current, String total);

  /// No description provided for @dichVuCuaBan.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ của bạn'**
  String get dichVuCuaBan;

  /// No description provided for @themItNhatMotDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ít nhất một dịch vụ bạn cung cấp.'**
  String get themItNhatMotDichVu;

  /// No description provided for @themDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Thêm dịch vụ'**
  String get themDichVu;

  /// No description provided for @loaiDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Loại dịch vụ'**
  String get loaiDichVu;

  /// No description provided for @datThuCung.
  ///
  /// In vi, this message translates to:
  /// **'Dắt thú cưng'**
  String get datThuCung;

  /// No description provided for @trongGiu.
  ///
  /// In vi, this message translates to:
  /// **'Trông giữ'**
  String get trongGiu;

  /// No description provided for @catTia.
  ///
  /// In vi, this message translates to:
  /// **'Cắt tỉa'**
  String get catTia;

  /// No description provided for @nhanLoai.
  ///
  /// In vi, this message translates to:
  /// **'Nhận loài'**
  String get nhanLoai;

  /// No description provided for @cho.
  ///
  /// In vi, this message translates to:
  /// **'Chó'**
  String get cho;

  /// No description provided for @meo.
  ///
  /// In vi, this message translates to:
  /// **'Mèo'**
  String get meo;

  /// No description provided for @caHai.
  ///
  /// In vi, this message translates to:
  /// **'Cả hai'**
  String get caHai;

  /// No description provided for @chiHoTroChoMeo.
  ///
  /// In vi, this message translates to:
  /// **'Hiện chỉ hỗ trợ chó và mèo.'**
  String get chiHoTroChoMeo;

  /// No description provided for @tenDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Tên dịch vụ'**
  String get tenDichVu;

  /// No description provided for @viDuDatCho.
  ///
  /// In vi, this message translates to:
  /// **'VD: Dắt chó buổi sáng'**
  String get viDuDatCho;

  /// No description provided for @viDuTrongGiu.
  ///
  /// In vi, this message translates to:
  /// **'VD: Trông giữ ban ngày'**
  String get viDuTrongGiu;

  /// No description provided for @viDuCatTia.
  ///
  /// In vi, this message translates to:
  /// **'VD: Cắt tỉa - tạo kiểu'**
  String get viDuCatTia;

  /// No description provided for @moTaDvDat.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ dắt tính theo lượt · cho 1 bé.'**
  String get moTaDvDat;

  /// No description provided for @moTaDvTrongGiu.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ trông giữ tính theo ngày · cho 1 bé.'**
  String get moTaDvTrongGiu;

  /// No description provided for @moTaDvCatTia.
  ///
  /// In vi, this message translates to:
  /// **'Cắt tỉa tính giá theo cân nặng · cho 1 bé.'**
  String get moTaDvCatTia;

  /// No description provided for @thoiLuongMoiLuot.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng mỗi lượt'**
  String get thoiLuongMoiLuot;

  /// No description provided for @soPhut.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String soPhut(String minutes);

  /// No description provided for @giaDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Giá dịch vụ'**
  String get giaDichVu;

  /// No description provided for @donGiaLuot.
  ///
  /// In vi, this message translates to:
  /// **'đ / lượt / bé'**
  String get donGiaLuot;

  /// No description provided for @donGiaNgay.
  ///
  /// In vi, this message translates to:
  /// **'đ / ngày / bé'**
  String get donGiaNgay;

  /// No description provided for @donGiaBe.
  ///
  /// In vi, this message translates to:
  /// **'đ / bé'**
  String get donGiaBe;

  /// No description provided for @sucChuaToiDa.
  ///
  /// In vi, this message translates to:
  /// **'Sức chứa tối đa'**
  String get sucChuaToiDa;

  /// No description provided for @hintSucChua.
  ///
  /// In vi, this message translates to:
  /// **'Số bé nhận cùng lúc (VD: 5)'**
  String get hintSucChua;

  /// No description provided for @bangGiaCanNang.
  ///
  /// In vi, this message translates to:
  /// **'Bảng giá theo cân nặng'**
  String get bangGiaCanNang;

  /// No description provided for @duoi5kg.
  ///
  /// In vi, this message translates to:
  /// **'Dưới 5 kg'**
  String get duoi5kg;

  /// No description provided for @tu5den10kg.
  ///
  /// In vi, this message translates to:
  /// **'5 - 10 kg'**
  String get tu5den10kg;

  /// No description provided for @tu10den20kg.
  ///
  /// In vi, this message translates to:
  /// **'10 - 20 kg'**
  String get tu10den20kg;

  /// No description provided for @tren20kg.
  ///
  /// In vi, this message translates to:
  /// **'Trên 20 kg'**
  String get tren20kg;

  /// No description provided for @luuDichVu.
  ///
  /// In vi, this message translates to:
  /// **'Lưu dịch vụ'**
  String get luuDichVu;

  /// No description provided for @thongTinCaNhan.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get thongTinCaNhan;

  /// No description provided for @nhapDungGiayTo.
  ///
  /// In vi, this message translates to:
  /// **'Nhập đúng theo giấy tờ tùy thân.'**
  String get nhapDungGiayTo;

  /// No description provided for @hoVaTenThat.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên thật'**
  String get hoVaTenThat;

  /// No description provided for @hintHoTenThat.
  ///
  /// In vi, this message translates to:
  /// **'Nguyễn Văn A'**
  String get hintHoTenThat;

  /// No description provided for @soCccd.
  ///
  /// In vi, this message translates to:
  /// **'Số CCCD'**
  String get soCccd;

  /// No description provided for @hintCccd.
  ///
  /// In vi, this message translates to:
  /// **'12 chữ số trên thẻ CCCD'**
  String get hintCccd;

  /// No description provided for @cccdKhongHopLe.
  ///
  /// In vi, this message translates to:
  /// **'Số CCCD phải đủ 12 chữ số'**
  String get cccdKhongHopLe;

  /// No description provided for @diaChiThuongTru.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ thường trú'**
  String get diaChiThuongTru;

  /// No description provided for @chonTinhThanh.
  ///
  /// In vi, this message translates to:
  /// **'Chọn Tỉnh/Thành phố'**
  String get chonTinhThanh;

  /// No description provided for @hintDiaChiChiTiet.
  ///
  /// In vi, this message translates to:
  /// **'Số nhà, đường, phường/xã'**
  String get hintDiaChiChiTiet;

  /// No description provided for @noiCap.
  ///
  /// In vi, this message translates to:
  /// **'Nơi cấp'**
  String get noiCap;

  /// No description provided for @hintNoiCap.
  ///
  /// In vi, this message translates to:
  /// **'Cục CSQLHC'**
  String get hintNoiCap;

  /// No description provided for @ngayCap.
  ///
  /// In vi, this message translates to:
  /// **'Ngày cấp'**
  String get ngayCap;

  /// No description provided for @hintNgayCap.
  ///
  /// In vi, this message translates to:
  /// **'dd/mm/yyyy'**
  String get hintNgayCap;

  /// No description provided for @khongDuocDeTrong.
  ///
  /// In vi, this message translates to:
  /// **'Không được để trống'**
  String get khongDuocDeTrong;

  /// No description provided for @taiLenCccd.
  ///
  /// In vi, this message translates to:
  /// **'Tải lên CCCD'**
  String get taiLenCccd;

  /// No description provided for @anhRoNet.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh rõ nét, đủ 4 góc, không bị lóa sáng.'**
  String get anhRoNet;

  /// No description provided for @anhCccd.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh CCCD'**
  String get anhCccd;

  /// No description provided for @matTruoc.
  ///
  /// In vi, this message translates to:
  /// **'Mặt trước'**
  String get matTruoc;

  /// No description provided for @matSau.
  ///
  /// In vi, this message translates to:
  /// **'Mặt sau'**
  String get matSau;

  /// No description provided for @thongTinKhopBuocTruoc.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin trên ảnh phải khớp với bước trước.'**
  String get thongTinKhopBuocTruoc;

  /// No description provided for @vuiLongTaiDuAnh.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng tải đủ ảnh mặt trước và mặt sau'**
  String get vuiLongTaiDuAnh;

  /// No description provided for @camKetDieuKhoan.
  ///
  /// In vi, this message translates to:
  /// **'Cam kết & điều khoản'**
  String get camKetDieuKhoan;

  /// No description provided for @xacNhanTrachNhiem.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận trách nhiệm trước khi gửi hồ sơ.'**
  String get xacNhanTrachNhiem;

  /// No description provided for @camKetTrachNhiemNcc.
  ///
  /// In vi, this message translates to:
  /// **'Cam kết & trách nhiệm nhà cung cấp'**
  String get camKetTrachNhiemNcc;

  /// No description provided for @camKet1.
  ///
  /// In vi, this message translates to:
  /// **'Chăm sóc tận tâm, an toàn cho thú cưng'**
  String get camKet1;

  /// No description provided for @camKet2.
  ///
  /// In vi, this message translates to:
  /// **'Cung cấp thông tin trung thực, chính xác'**
  String get camKet2;

  /// No description provided for @camKet3.
  ///
  /// In vi, this message translates to:
  /// **'Chịu trách nhiệm pháp lý về chất lượng & an toàn dịch vụ'**
  String get camKet3;

  /// No description provided for @nenTangTrungGian.
  ///
  /// In vi, this message translates to:
  /// **'Smart Pet Care là nền tảng trung gian kết nối, không phải bên cung cấp dịch vụ.'**
  String get nenTangTrungGian;

  /// No description provided for @dongYDieuKhoan.
  ///
  /// In vi, this message translates to:
  /// **'Tôi đồng ý với Cam kết, Điều khoản dịch vụ và Chính sách bảo mật.'**
  String get dongYDieuKhoan;

  /// No description provided for @batBuoc.
  ///
  /// In vi, this message translates to:
  /// **'* Bắt buộc'**
  String get batBuoc;

  /// No description provided for @hoanTatGuiHoSo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất & gửi hồ sơ'**
  String get hoanTatGuiHoSo;

  /// No description provided for @hoSoDuyet24h.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ được duyệt trong vòng 24 giờ. Bạn sẽ nhận thông báo để cập nhật hồ sơ sau khi được duyệt.'**
  String get hoSoDuyet24h;

  /// No description provided for @vuiLongDongY.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đồng ý với điều khoản để tiếp tục'**
  String get vuiLongDongY;

  /// No description provided for @daGuiHoSo.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi hồ sơ!'**
  String get daGuiHoSo;

  /// No description provided for @hoSoDangXemXet.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của bạn đang được xem xét, thường trong vòng 24 giờ. Chúng tôi sẽ gửi thông báo ngay khi có kết quả.'**
  String get hoSoDangXemXet;

  /// No description provided for @trongLucChoDungChuNuoi.
  ///
  /// In vi, this message translates to:
  /// **'Trong lúc chờ, bạn vẫn có thể dùng app với vai trò Chủ nuôi.'**
  String get trongLucChoDungChuNuoi;

  /// No description provided for @veTrangChu.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get veTrangChu;

  /// No description provided for @xemTrangThaiHoSo.
  ///
  /// In vi, this message translates to:
  /// **'Xem trạng thái hồ sơ'**
  String get xemTrangThaiHoSo;

  /// No description provided for @loiKetNoiMayChu.
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối máy chủ, vui lòng thử lại'**
  String get loiKetNoiMayChu;

  /// No description provided for @loiEmailDaSuDung.
  ///
  /// In vi, this message translates to:
  /// **'Email đã được sử dụng'**
  String get loiEmailDaSuDung;

  /// No description provided for @loiSoDienThoaiDaSuDung.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại đã được sử dụng'**
  String get loiSoDienThoaiDaSuDung;

  /// No description provided for @loiTaiKhoanKhongTonTai.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản không tồn tại'**
  String get loiTaiKhoanKhongTonTai;

  /// No description provided for @loiEmailDaXacMinh.
  ///
  /// In vi, this message translates to:
  /// **'Email đã được xác minh, vui lòng đăng nhập'**
  String get loiEmailDaXacMinh;

  /// No description provided for @loiMaOtpKhongDung.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác minh không đúng'**
  String get loiMaOtpKhongDung;

  /// No description provided for @loiMaOtpHetHan.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác minh đã hết hạn, vui lòng gửi lại mã'**
  String get loiMaOtpHetHan;

  /// No description provided for @loiGuiLaiOtpQuaSom.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chờ 30 giây trước khi gửi lại mã'**
  String get loiGuiLaiOtpQuaSom;

  /// No description provided for @loiOtpBiKhoa.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã nhập sai quá nhiều lần, vui lòng thử lại sau {phut} phút'**
  String loiOtpBiKhoa(int phut);

  /// No description provided for @vuiLongThuLaiSau.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng thử lại sau {time}'**
  String vuiLongThuLaiSau(String time);

  /// No description provided for @loiNhapSaiQuaSoLan.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã nhập sai quá {soLan} lần'**
  String loiNhapSaiQuaSoLan(int soLan);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
