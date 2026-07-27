// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sitter_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SitterProfileNotifier)
final sitterProfileProvider = SitterProfileNotifierProvider._();

final class SitterProfileNotifierProvider
    extends $NotifierProvider<SitterProfileNotifier, SitterProfileDraft> {
  SitterProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sitterProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sitterProfileNotifierHash();

  @$internal
  @override
  SitterProfileNotifier create() => SitterProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SitterProfileDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SitterProfileDraft>(value),
    );
  }
}

String _$sitterProfileNotifierHash() =>
    r'bd347080131a143b1555cf8a46cb09fcb9f6262c';

abstract class _$SitterProfileNotifier extends $Notifier<SitterProfileDraft> {
  SitterProfileDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SitterProfileDraft, SitterProfileDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SitterProfileDraft, SitterProfileDraft>,
              SitterProfileDraft,
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

String _$sitterStatusHash() => r'9cd0f7b64e5ad81d05dc1bed622f0c6926421100';
