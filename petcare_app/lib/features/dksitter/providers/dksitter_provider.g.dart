// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dksitter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DkSitterNotifier)
final dkSitterProvider = DkSitterNotifierProvider._();

final class DkSitterNotifierProvider
    extends $NotifierProvider<DkSitterNotifier, DkSitterDraft> {
  DkSitterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dkSitterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dkSitterNotifierHash();

  @$internal
  @override
  DkSitterNotifier create() => DkSitterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DkSitterDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DkSitterDraft>(value),
    );
  }
}

String _$dkSitterNotifierHash() => r'b78d1746974803a0a00c6c2fbf994d97462dece3';

abstract class _$DkSitterNotifier extends $Notifier<DkSitterDraft> {
  DkSitterDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DkSitterDraft, DkSitterDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DkSitterDraft, DkSitterDraft>,
              DkSitterDraft,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(sitterStatus)
final sitterStatusProvider = SitterStatusProvider._();

final class SitterStatusProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  SitterStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sitterStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sitterStatusHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return sitterStatus(ref);
  }
}

String _$sitterStatusHash() => r'9838fa308a459abe9595b4aaaaada545107a41ec';
