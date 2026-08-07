// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_results_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KetQuaTim)
final ketQuaTimProvider = KetQuaTimFamily._();

final class KetQuaTimProvider
    extends $AsyncNotifierProvider<KetQuaTim, TrangKetQuaTim> {
  KetQuaTimProvider._({
    required KetQuaTimFamily super.from,
    required YeuCauTim super.argument,
  }) : super(
         retry: null,
         name: r'ketQuaTimProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ketQuaTimHash();

  @override
  String toString() {
    return r'ketQuaTimProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  KetQuaTim create() => KetQuaTim();

  @override
  bool operator ==(Object other) {
    return other is KetQuaTimProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ketQuaTimHash() => r'e20d2600b45639d681d309904423b2f729d78fe8';

final class KetQuaTimFamily extends $Family
    with
        $ClassFamilyOverride<
          KetQuaTim,
          AsyncValue<TrangKetQuaTim>,
          TrangKetQuaTim,
          FutureOr<TrangKetQuaTim>,
          YeuCauTim
        > {
  KetQuaTimFamily._()
    : super(
        retry: null,
        name: r'ketQuaTimProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  KetQuaTimProvider call(YeuCauTim yeuCau) =>
      KetQuaTimProvider._(argument: yeuCau, from: this);

  @override
  String toString() => r'ketQuaTimProvider';
}

abstract class _$KetQuaTim extends $AsyncNotifier<TrangKetQuaTim> {
  late final _$args = ref.$arg as YeuCauTim;
  YeuCauTim get yeuCau => _$args;

  FutureOr<TrangKetQuaTim> build(YeuCauTim yeuCau);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrangKetQuaTim>, TrangKetQuaTim>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrangKetQuaTim>, TrangKetQuaTim>,
              AsyncValue<TrangKetQuaTim>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
