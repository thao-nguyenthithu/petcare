// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(danhGiaNguoiCham)
final danhGiaNguoiChamProvider = DanhGiaNguoiChamFamily._();

final class DanhGiaNguoiChamProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrangDanhGia>,
          TrangDanhGia,
          FutureOr<TrangDanhGia>
        >
    with $FutureModifier<TrangDanhGia>, $FutureProvider<TrangDanhGia> {
  DanhGiaNguoiChamProvider._({
    required DanhGiaNguoiChamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'danhGiaNguoiChamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$danhGiaNguoiChamHash();

  @override
  String toString() {
    return r'danhGiaNguoiChamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TrangDanhGia> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrangDanhGia> create(Ref ref) {
    final argument = this.argument as String;
    return danhGiaNguoiCham(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DanhGiaNguoiChamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$danhGiaNguoiChamHash() => r'573532be2486862a20907d1ddd3d2ecaa88aa5a6';

final class DanhGiaNguoiChamFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TrangDanhGia>, String> {
  DanhGiaNguoiChamFamily._()
    : super(
        retry: null,
        name: r'danhGiaNguoiChamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DanhGiaNguoiChamProvider call(String sitterId) =>
      DanhGiaNguoiChamProvider._(argument: sitterId, from: this);

  @override
  String toString() => r'danhGiaNguoiChamProvider';
}

@ProviderFor(DanhGiaVeToi)
final danhGiaVeToiProvider = DanhGiaVeToiProvider._();

final class DanhGiaVeToiProvider
    extends $AsyncNotifierProvider<DanhGiaVeToi, TrangDanhGia> {
  DanhGiaVeToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'danhGiaVeToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$danhGiaVeToiHash();

  @$internal
  @override
  DanhGiaVeToi create() => DanhGiaVeToi();
}

String _$danhGiaVeToiHash() => r'656550d5725cb9f8a556ab96eba44befeb87fd15';

abstract class _$DanhGiaVeToi extends $AsyncNotifier<TrangDanhGia> {
  FutureOr<TrangDanhGia> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrangDanhGia>, TrangDanhGia>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrangDanhGia>, TrangDanhGia>,
              AsyncValue<TrangDanhGia>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DanhGiaCuaToi)
final danhGiaCuaToiProvider = DanhGiaCuaToiProvider._();

final class DanhGiaCuaToiProvider
    extends $AsyncNotifierProvider<DanhGiaCuaToi, TrangDanhGia> {
  DanhGiaCuaToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'danhGiaCuaToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$danhGiaCuaToiHash();

  @$internal
  @override
  DanhGiaCuaToi create() => DanhGiaCuaToi();
}

String _$danhGiaCuaToiHash() => r'39766ddb8f26408f68ebb79f5874320cf59ab5bb';

abstract class _$DanhGiaCuaToi extends $AsyncNotifier<TrangDanhGia> {
  FutureOr<TrangDanhGia> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrangDanhGia>, TrangDanhGia>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrangDanhGia>, TrangDanhGia>,
              AsyncValue<TrangDanhGia>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DonChoDanhGiaCuaToi)
final donChoDanhGiaCuaToiProvider = DonChoDanhGiaCuaToiProvider._();

final class DonChoDanhGiaCuaToiProvider
    extends $AsyncNotifierProvider<DonChoDanhGiaCuaToi, List<DonChoDanhGia>> {
  DonChoDanhGiaCuaToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donChoDanhGiaCuaToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donChoDanhGiaCuaToiHash();

  @$internal
  @override
  DonChoDanhGiaCuaToi create() => DonChoDanhGiaCuaToi();
}

String _$donChoDanhGiaCuaToiHash() =>
    r'0b1b9ab0ad2229193ce255d70b6eb30d773aa993';

abstract class _$DonChoDanhGiaCuaToi
    extends $AsyncNotifier<List<DonChoDanhGia>> {
  FutureOr<List<DonChoDanhGia>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DonChoDanhGia>>, List<DonChoDanhGia>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DonChoDanhGia>>, List<DonChoDanhGia>>,
              AsyncValue<List<DonChoDanhGia>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
