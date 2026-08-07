// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HoiThoaiChuNuoi)
final hoiThoaiChuNuoiProvider = HoiThoaiChuNuoiProvider._();

final class HoiThoaiChuNuoiProvider
    extends $AsyncNotifierProvider<HoiThoaiChuNuoi, List<Conversation>> {
  HoiThoaiChuNuoiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hoiThoaiChuNuoiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hoiThoaiChuNuoiHash();

  @$internal
  @override
  HoiThoaiChuNuoi create() => HoiThoaiChuNuoi();
}

String _$hoiThoaiChuNuoiHash() => r'63272a5919571bfb9f9e341bf128ad1bae9acd13';

abstract class _$HoiThoaiChuNuoi extends $AsyncNotifier<List<Conversation>> {
  FutureOr<List<Conversation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Conversation>>, List<Conversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Conversation>>, List<Conversation>>,
              AsyncValue<List<Conversation>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HoiThoaiNguoiCham)
final hoiThoaiNguoiChamProvider = HoiThoaiNguoiChamProvider._();

final class HoiThoaiNguoiChamProvider
    extends $AsyncNotifierProvider<HoiThoaiNguoiCham, List<Conversation>> {
  HoiThoaiNguoiChamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hoiThoaiNguoiChamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hoiThoaiNguoiChamHash();

  @$internal
  @override
  HoiThoaiNguoiCham create() => HoiThoaiNguoiCham();
}

String _$hoiThoaiNguoiChamHash() => r'94a9963e04c1b280b68b0d70689c9fdcb7c44da4';

abstract class _$HoiThoaiNguoiCham extends $AsyncNotifier<List<Conversation>> {
  FutureOr<List<Conversation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Conversation>>, List<Conversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Conversation>>, List<Conversation>>,
              AsyncValue<List<Conversation>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(soChuaDocChuNuoi)
final soChuaDocChuNuoiProvider = SoChuaDocChuNuoiProvider._();

final class SoChuaDocChuNuoiProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  SoChuaDocChuNuoiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soChuaDocChuNuoiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soChuaDocChuNuoiHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return soChuaDocChuNuoi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$soChuaDocChuNuoiHash() => r'a06e842472e1c36d11f3634d45a6fdf4189f2114';

@ProviderFor(soChuaDocNguoiCham)
final soChuaDocNguoiChamProvider = SoChuaDocNguoiChamProvider._();

final class SoChuaDocNguoiChamProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  SoChuaDocNguoiChamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soChuaDocNguoiChamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soChuaDocNguoiChamHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return soChuaDocNguoiCham(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$soChuaDocNguoiChamHash() =>
    r'c530b6644d6d8e489fbb460980ddcf359bf165d6';
