// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sitter_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sitterBookings)
final sitterBookingsProvider = SitterBookingsFamily._();

final class SitterBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrangDonNcc>,
          TrangDonNcc,
          FutureOr<TrangDonNcc>
        >
    with $FutureModifier<TrangDonNcc>, $FutureProvider<TrangDonNcc> {
  SitterBookingsProvider._({
    required SitterBookingsFamily super.from,
    required (ChipDonNcc, ServiceType?) super.argument,
  }) : super(
         retry: null,
         name: r'sitterBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sitterBookingsHash();

  @override
  String toString() {
    return r'sitterBookingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TrangDonNcc> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrangDonNcc> create(Ref ref) {
    final argument = this.argument as (ChipDonNcc, ServiceType?);
    return sitterBookings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SitterBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sitterBookingsHash() => r'ab25761e2b5d924e64e5443c0afaefa834f405a3';

final class SitterBookingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<TrangDonNcc>,
          (ChipDonNcc, ServiceType?)
        > {
  SitterBookingsFamily._()
    : super(
        retry: null,
        name: r'sitterBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SitterBookingsProvider call(ChipDonNcc chip, ServiceType? loai) =>
      SitterBookingsProvider._(argument: (chip, loai), from: this);

  @override
  String toString() => r'sitterBookingsProvider';
}

@ProviderFor(tomTatDonNcc)
final tomTatDonNccProvider = TomTatDonNccProvider._();

final class TomTatDonNccProvider
    extends
        $FunctionalProvider<
          AsyncValue<TomTatDonNcc>,
          TomTatDonNcc,
          FutureOr<TomTatDonNcc>
        >
    with $FutureModifier<TomTatDonNcc>, $FutureProvider<TomTatDonNcc> {
  TomTatDonNccProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tomTatDonNccProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tomTatDonNccHash();

  @$internal
  @override
  $FutureProviderElement<TomTatDonNcc> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TomTatDonNcc> create(Ref ref) {
    return tomTatDonNcc(ref);
  }
}

String _$tomTatDonNccHash() => r'332e153a422dc8c24a4e2a78838cce4ea34341b3';

@ProviderFor(ChiTietDonNcc)
final chiTietDonNccProvider = ChiTietDonNccFamily._();

final class ChiTietDonNccProvider
    extends $AsyncNotifierProvider<ChiTietDonNcc, ChiTietDonNccApi> {
  ChiTietDonNccProvider._({
    required ChiTietDonNccFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chiTietDonNccProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chiTietDonNccHash();

  @override
  String toString() {
    return r'chiTietDonNccProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChiTietDonNcc create() => ChiTietDonNcc();

  @override
  bool operator ==(Object other) {
    return other is ChiTietDonNccProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chiTietDonNccHash() => r'ead226a7d0a619c4bddb66bfaf3856bf0c87ee77';

final class ChiTietDonNccFamily extends $Family
    with
        $ClassFamilyOverride<
          ChiTietDonNcc,
          AsyncValue<ChiTietDonNccApi>,
          ChiTietDonNccApi,
          FutureOr<ChiTietDonNccApi>,
          String
        > {
  ChiTietDonNccFamily._()
    : super(
        retry: null,
        name: r'chiTietDonNccProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChiTietDonNccProvider call(String bookingId) =>
      ChiTietDonNccProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'chiTietDonNccProvider';
}

abstract class _$ChiTietDonNcc extends $AsyncNotifier<ChiTietDonNccApi> {
  late final _$args = ref.$arg as String;
  String get bookingId => _$args;

  FutureOr<ChiTietDonNccApi> build(String bookingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ChiTietDonNccApi>, ChiTietDonNccApi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChiTietDonNccApi>, ChiTietDonNccApi>,
              AsyncValue<ChiTietDonNccApi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
