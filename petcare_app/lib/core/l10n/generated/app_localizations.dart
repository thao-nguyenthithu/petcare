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

  /// No description provided for @banLa.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là'**
  String get banLa;

  /// No description provided for @chuNuoi.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nuôi'**
  String get chuNuoi;

  /// No description provided for @nguoiCungCap.
  ///
  /// In vi, this message translates to:
  /// **'Người cung cấp'**
  String get nguoiCungCap;

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
