// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_booking_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookingDetail)
final bookingDetailProvider = BookingDetailFamily._();

final class BookingDetailProvider
    extends $AsyncNotifierProvider<BookingDetail, ChiTietDonApi> {
  BookingDetailProvider._({
    required BookingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingDetailHash();

  @override
  String toString() {
    return r'bookingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BookingDetail create() => BookingDetail();

  @override
  bool operator ==(Object other) {
    return other is BookingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingDetailHash() => r'46abdeec7c81bc09c5992a04f7d6316f8268e4eb';

final class BookingDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          BookingDetail,
          AsyncValue<ChiTietDonApi>,
          ChiTietDonApi,
          FutureOr<ChiTietDonApi>,
          String
        > {
  BookingDetailFamily._()
    : super(
        retry: null,
        name: r'bookingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookingDetailProvider call(String bookingId) =>
      BookingDetailProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingDetailProvider';
}

abstract class _$BookingDetail extends $AsyncNotifier<ChiTietDonApi> {
  late final _$args = ref.$arg as String;
  String get bookingId => _$args;

  FutureOr<ChiTietDonApi> build(String bookingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ChiTietDonApi>, ChiTietDonApi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChiTietDonApi>, ChiTietDonApi>,
              AsyncValue<ChiTietDonApi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
