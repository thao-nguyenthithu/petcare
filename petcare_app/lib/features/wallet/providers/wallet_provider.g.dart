// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ViCuaToi)
final viCuaToiProvider = ViCuaToiProvider._();

final class ViCuaToiProvider extends $AsyncNotifierProvider<ViCuaToi, ViApi> {
  ViCuaToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viCuaToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viCuaToiHash();

  @$internal
  @override
  ViCuaToi create() => ViCuaToi();
}

String _$viCuaToiHash() => r'a6a9d22416a565e6c9d6403ca16c18cbe5c7e560';

abstract class _$ViCuaToi extends $AsyncNotifier<ViApi> {
  FutureOr<ViApi> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ViApi>, ViApi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ViApi>, ViApi>,
              AsyncValue<ViApi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(lichSuVi)
final lichSuViProvider = LichSuViFamily._();

final class LichSuViProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrangGiaoDichVi>,
          TrangGiaoDichVi,
          FutureOr<TrangGiaoDichVi>
        >
    with $FutureModifier<TrangGiaoDichVi>, $FutureProvider<TrangGiaoDichVi> {
  LichSuViProvider._({
    required LichSuViFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'lichSuViProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lichSuViHash();

  @override
  String toString() {
    return r'lichSuViProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TrangGiaoDichVi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrangGiaoDichVi> create(Ref ref) {
    final argument = this.argument as String?;
    return lichSuVi(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LichSuViProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lichSuViHash() => r'38b8c23da7afa92debb720ad596e40c121df0d92';

final class LichSuViFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TrangGiaoDichVi>, String?> {
  LichSuViFamily._()
    : super(
        retry: null,
        name: r'lichSuViProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LichSuViProvider call(String? loai) =>
      LichSuViProvider._(argument: loai, from: this);

  @override
  String toString() => r'lichSuViProvider';
}

@ProviderFor(chiTietGiaoDichVi)
final chiTietGiaoDichViProvider = ChiTietGiaoDichViFamily._();

final class ChiTietGiaoDichViProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChiTietGiaoDichApi>,
          ChiTietGiaoDichApi,
          FutureOr<ChiTietGiaoDichApi>
        >
    with
        $FutureModifier<ChiTietGiaoDichApi>,
        $FutureProvider<ChiTietGiaoDichApi> {
  ChiTietGiaoDichViProvider._({
    required ChiTietGiaoDichViFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chiTietGiaoDichViProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chiTietGiaoDichViHash();

  @override
  String toString() {
    return r'chiTietGiaoDichViProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChiTietGiaoDichApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChiTietGiaoDichApi> create(Ref ref) {
    final argument = this.argument as String;
    return chiTietGiaoDichVi(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChiTietGiaoDichViProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chiTietGiaoDichViHash() => r'210ab211dbd9ef19672f5fe6aa7deb7491c8f64b';

final class ChiTietGiaoDichViFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChiTietGiaoDichApi>, String> {
  ChiTietGiaoDichViFamily._()
    : super(
        retry: null,
        name: r'chiTietGiaoDichViProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChiTietGiaoDichViProvider call(String ma) =>
      ChiTietGiaoDichViProvider._(argument: ma, from: this);

  @override
  String toString() => r'chiTietGiaoDichViProvider';
}

@ProviderFor(TaiKhoanNhanTien)
final taiKhoanNhanTienProvider = TaiKhoanNhanTienProvider._();

final class TaiKhoanNhanTienProvider
    extends $AsyncNotifierProvider<TaiKhoanNhanTien, TaiKhoanNganHangApi?> {
  TaiKhoanNhanTienProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taiKhoanNhanTienProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taiKhoanNhanTienHash();

  @$internal
  @override
  TaiKhoanNhanTien create() => TaiKhoanNhanTien();
}

String _$taiKhoanNhanTienHash() => r'a5a613f1219de083f65087738275f1c352621cc1';

abstract class _$TaiKhoanNhanTien extends $AsyncNotifier<TaiKhoanNganHangApi?> {
  FutureOr<TaiKhoanNganHangApi?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TaiKhoanNganHangApi?>, TaiKhoanNganHangApi?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaiKhoanNganHangApi?>,
                TaiKhoanNganHangApi?
              >,
              AsyncValue<TaiKhoanNganHangApi?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(hoSoKhieuNai)
final hoSoKhieuNaiProvider = HoSoKhieuNaiFamily._();

final class HoSoKhieuNaiProvider
    extends
        $FunctionalProvider<
          AsyncValue<HoSoKhieuNaiApi>,
          HoSoKhieuNaiApi,
          FutureOr<HoSoKhieuNaiApi>
        >
    with $FutureModifier<HoSoKhieuNaiApi>, $FutureProvider<HoSoKhieuNaiApi> {
  HoSoKhieuNaiProvider._({
    required HoSoKhieuNaiFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hoSoKhieuNaiProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hoSoKhieuNaiHash();

  @override
  String toString() {
    return r'hoSoKhieuNaiProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HoSoKhieuNaiApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HoSoKhieuNaiApi> create(Ref ref) {
    final argument = this.argument as String;
    return hoSoKhieuNai(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HoSoKhieuNaiProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hoSoKhieuNaiHash() => r'4f43df7e6298a2d93049535434529425d1e0feb5';

final class HoSoKhieuNaiFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HoSoKhieuNaiApi>, String> {
  HoSoKhieuNaiFamily._()
    : super(
        retry: null,
        name: r'hoSoKhieuNaiProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HoSoKhieuNaiProvider call(String ma) =>
      HoSoKhieuNaiProvider._(argument: ma, from: this);

  @override
  String toString() => r'hoSoKhieuNaiProvider';
}

@ProviderFor(thuNhapTheoKy)
final thuNhapTheoKyProvider = ThuNhapTheoKyFamily._();

final class ThuNhapTheoKyProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThuNhapApi>,
          ThuNhapApi,
          FutureOr<ThuNhapApi>
        >
    with $FutureModifier<ThuNhapApi>, $FutureProvider<ThuNhapApi> {
  ThuNhapTheoKyProvider._({
    required ThuNhapTheoKyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'thuNhapTheoKyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$thuNhapTheoKyHash();

  @override
  String toString() {
    return r'thuNhapTheoKyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ThuNhapApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ThuNhapApi> create(Ref ref) {
    final argument = this.argument as String;
    return thuNhapTheoKy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ThuNhapTheoKyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$thuNhapTheoKyHash() => r'd006ea67e2e3c9ac03c4c5129b1dd1701b12c309';

final class ThuNhapTheoKyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ThuNhapApi>, String> {
  ThuNhapTheoKyFamily._()
    : super(
        retry: null,
        name: r'thuNhapTheoKyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThuNhapTheoKyProvider call(String ky) =>
      ThuNhapTheoKyProvider._(argument: ky, from: this);

  @override
  String toString() => r'thuNhapTheoKyProvider';
}

@ProviderFor(walletApi)
final walletApiProvider = WalletApiProvider._();

final class WalletApiProvider
    extends
        $FunctionalProvider<
          WalletApiService,
          WalletApiService,
          WalletApiService
        >
    with $Provider<WalletApiService> {
  WalletApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletApiHash();

  @$internal
  @override
  $ProviderElement<WalletApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WalletApiService create(Ref ref) {
    return walletApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletApiService>(value),
    );
  }
}

String _$walletApiHash() => r'652d2a64d619fc76241a2d8249cc10f9cdb72bec';
