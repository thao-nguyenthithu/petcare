// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_sitters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nguoiChamGanBan)
final nguoiChamGanBanProvider = NguoiChamGanBanProvider._();

final class NguoiChamGanBanProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SitterResult>>,
          List<SitterResult>,
          FutureOr<List<SitterResult>>
        >
    with
        $FutureModifier<List<SitterResult>>,
        $FutureProvider<List<SitterResult>> {
  NguoiChamGanBanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nguoiChamGanBanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nguoiChamGanBanHash();

  @$internal
  @override
  $FutureProviderElement<List<SitterResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SitterResult>> create(Ref ref) {
    return nguoiChamGanBan(ref);
  }
}

String _$nguoiChamGanBanHash() => r'564b956e06764c31c7c76c9800a52655859d329e';

@ProviderFor(nguoiChamDanhGiaCao)
final nguoiChamDanhGiaCaoProvider = NguoiChamDanhGiaCaoProvider._();

final class NguoiChamDanhGiaCaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SitterResult>>,
          List<SitterResult>,
          FutureOr<List<SitterResult>>
        >
    with
        $FutureModifier<List<SitterResult>>,
        $FutureProvider<List<SitterResult>> {
  NguoiChamDanhGiaCaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nguoiChamDanhGiaCaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nguoiChamDanhGiaCaoHash();

  @$internal
  @override
  $FutureProviderElement<List<SitterResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SitterResult>> create(Ref ref) {
    return nguoiChamDanhGiaCao(ref);
  }
}

String _$nguoiChamDanhGiaCaoHash() =>
    r'4e127667b1a9c14ebb558cc6797d9072c85d7381';
