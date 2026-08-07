// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TienDangTamGiu)
final tienDangTamGiuProvider = TienDangTamGiuProvider._();

final class TienDangTamGiuProvider
    extends $AsyncNotifierProvider<TienDangTamGiu, TienDangGiuApi> {
  TienDangTamGiuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tienDangTamGiuProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tienDangTamGiuHash();

  @$internal
  @override
  TienDangTamGiu create() => TienDangTamGiu();
}

String _$tienDangTamGiuHash() => r'0710b0952de059d29850e6f5ffa4006ad1d2ebe9';

abstract class _$TienDangTamGiu extends $AsyncNotifier<TienDangGiuApi> {
  FutureOr<TienDangGiuApi> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TienDangGiuApi>, TienDangGiuApi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TienDangGiuApi>, TienDangGiuApi>,
              AsyncValue<TienDangGiuApi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(lichSuThanhToan)
final lichSuThanhToanProvider = LichSuThanhToanFamily._();

final class LichSuThanhToanProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GiaoDichChuNuoiApi>>,
          List<GiaoDichChuNuoiApi>,
          FutureOr<List<GiaoDichChuNuoiApi>>
        >
    with
        $FutureModifier<List<GiaoDichChuNuoiApi>>,
        $FutureProvider<List<GiaoDichChuNuoiApi>> {
  LichSuThanhToanProvider._({
    required LichSuThanhToanFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'lichSuThanhToanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lichSuThanhToanHash();

  @override
  String toString() {
    return r'lichSuThanhToanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GiaoDichChuNuoiApi>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GiaoDichChuNuoiApi>> create(Ref ref) {
    final argument = this.argument as String?;
    return lichSuThanhToan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LichSuThanhToanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lichSuThanhToanHash() => r'e51e774c7582c56d46d731e88356bc17e36a15e5';

final class LichSuThanhToanFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<GiaoDichChuNuoiApi>>, String?> {
  LichSuThanhToanFamily._()
    : super(
        retry: null,
        name: r'lichSuThanhToanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LichSuThanhToanProvider call(String? loai) =>
      LichSuThanhToanProvider._(argument: loai, from: this);

  @override
  String toString() => r'lichSuThanhToanProvider';
}

@ProviderFor(chiTietThanhToan)
final chiTietThanhToanProvider = ChiTietThanhToanFamily._();

final class ChiTietThanhToanProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChiTietThanhToanApi>,
          ChiTietThanhToanApi,
          FutureOr<ChiTietThanhToanApi>
        >
    with
        $FutureModifier<ChiTietThanhToanApi>,
        $FutureProvider<ChiTietThanhToanApi> {
  ChiTietThanhToanProvider._({
    required ChiTietThanhToanFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chiTietThanhToanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chiTietThanhToanHash();

  @override
  String toString() {
    return r'chiTietThanhToanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChiTietThanhToanApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChiTietThanhToanApi> create(Ref ref) {
    final argument = this.argument as String;
    return chiTietThanhToan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChiTietThanhToanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chiTietThanhToanHash() => r'9d9bf388f4b308fd3620961b76e1475e5aa38b34';

final class ChiTietThanhToanFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChiTietThanhToanApi>, String> {
  ChiTietThanhToanFamily._()
    : super(
        retry: null,
        name: r'chiTietThanhToanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChiTietThanhToanProvider call(String ma) =>
      ChiTietThanhToanProvider._(argument: ma, from: this);

  @override
  String toString() => r'chiTietThanhToanProvider';
}

@ProviderFor(chiTieuTheoKy)
final chiTieuTheoKyProvider = ChiTieuTheoKyFamily._();

final class ChiTieuTheoKyProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChiTieuApi>,
          ChiTieuApi,
          FutureOr<ChiTieuApi>
        >
    with $FutureModifier<ChiTieuApi>, $FutureProvider<ChiTieuApi> {
  ChiTieuTheoKyProvider._({
    required ChiTieuTheoKyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chiTieuTheoKyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chiTieuTheoKyHash();

  @override
  String toString() {
    return r'chiTieuTheoKyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChiTieuApi> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChiTieuApi> create(Ref ref) {
    final argument = this.argument as String;
    return chiTieuTheoKy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChiTieuTheoKyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chiTieuTheoKyHash() => r'b18c385b0ced85a2af26f230ed00d696d183f035';

final class ChiTieuTheoKyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChiTieuApi>, String> {
  ChiTieuTheoKyFamily._()
    : super(
        retry: null,
        name: r'chiTieuTheoKyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChiTieuTheoKyProvider call(String ky) =>
      ChiTieuTheoKyProvider._(argument: ky, from: this);

  @override
  String toString() => r'chiTieuTheoKyProvider';
}
