// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_bookings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OwnerBookings)
final ownerBookingsProvider = OwnerBookingsFamily._();

final class OwnerBookingsProvider
    extends $AsyncNotifierProvider<OwnerBookings, TrangDonCuaToi> {
  OwnerBookingsProvider._({
    required OwnerBookingsFamily super.from,
    required (BookingStatus, PetServiceType?, String) super.argument,
  }) : super(
         retry: null,
         name: r'ownerBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ownerBookingsHash();

  @override
  String toString() {
    return r'ownerBookingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  OwnerBookings create() => OwnerBookings();

  @override
  bool operator ==(Object other) {
    return other is OwnerBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ownerBookingsHash() => r'c4de166562c3c71c12eac1d1e6b2bce49efa8796';

final class OwnerBookingsFamily extends $Family
    with
        $ClassFamilyOverride<
          OwnerBookings,
          AsyncValue<TrangDonCuaToi>,
          TrangDonCuaToi,
          FutureOr<TrangDonCuaToi>,
          (BookingStatus, PetServiceType?, String)
        > {
  OwnerBookingsFamily._()
    : super(
        retry: null,
        name: r'ownerBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OwnerBookingsProvider call(
    BookingStatus tab,
    PetServiceType? loai,
    String tuKhoa,
  ) => OwnerBookingsProvider._(argument: (tab, loai, tuKhoa), from: this);

  @override
  String toString() => r'ownerBookingsProvider';
}

abstract class _$OwnerBookings extends $AsyncNotifier<TrangDonCuaToi> {
  late final _$args = ref.$arg as (BookingStatus, PetServiceType?, String);
  BookingStatus get tab => _$args.$1;
  PetServiceType? get loai => _$args.$2;
  String get tuKhoa => _$args.$3;

  FutureOr<TrangDonCuaToi> build(
    BookingStatus tab,
    PetServiceType? loai,
    String tuKhoa,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrangDonCuaToi>, TrangDonCuaToi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrangDonCuaToi>, TrangDonCuaToi>,
              AsyncValue<TrangDonCuaToi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2, _$args.$3));
  }
}
