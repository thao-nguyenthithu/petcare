// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThongBaoCuaToi)
final thongBaoCuaToiProvider = ThongBaoCuaToiProvider._();

final class ThongBaoCuaToiProvider
    extends $AsyncNotifierProvider<ThongBaoCuaToi, List<ThongBao>> {
  ThongBaoCuaToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thongBaoCuaToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thongBaoCuaToiHash();

  @$internal
  @override
  ThongBaoCuaToi create() => ThongBaoCuaToi();
}

String _$thongBaoCuaToiHash() => r'84369082dbf78ee656357cdbd590a070e62755b6';

abstract class _$ThongBaoCuaToi extends $AsyncNotifier<List<ThongBao>> {
  FutureOr<List<ThongBao>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ThongBao>>, List<ThongBao>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ThongBao>>, List<ThongBao>>,
              AsyncValue<List<ThongBao>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(soThongBaoChuaDoc)
final soThongBaoChuaDocProvider = SoThongBaoChuaDocFamily._();

final class SoThongBaoChuaDocProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  SoThongBaoChuaDocProvider._({
    required SoThongBaoChuaDocFamily super.from,
    required VaiNhan? super.argument,
  }) : super(
         retry: null,
         name: r'soThongBaoChuaDocProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$soThongBaoChuaDocHash();

  @override
  String toString() {
    return r'soThongBaoChuaDocProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as VaiNhan?;
    return soThongBaoChuaDoc(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SoThongBaoChuaDocProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$soThongBaoChuaDocHash() => r'c72ceb5692325098266cdb78c08d6e90780403ae';

final class SoThongBaoChuaDocFamily extends $Family
    with $FunctionalFamilyOverride<int, VaiNhan?> {
  SoThongBaoChuaDocFamily._()
    : super(
        retry: null,
        name: r'soThongBaoChuaDocProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SoThongBaoChuaDocProvider call(VaiNhan? vai) =>
      SoThongBaoChuaDocProvider._(argument: vai, from: this);

  @override
  String toString() => r'soThongBaoChuaDocProvider';
}
