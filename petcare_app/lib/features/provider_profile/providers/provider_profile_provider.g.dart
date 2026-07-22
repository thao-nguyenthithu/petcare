// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProviderProfileNotifier)
final providerProfileProvider = ProviderProfileNotifierProvider._();

final class ProviderProfileNotifierProvider
    extends $NotifierProvider<ProviderProfileNotifier, ProviderProfileDraft> {
  ProviderProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerProfileNotifierHash();

  @$internal
  @override
  ProviderProfileNotifier create() => ProviderProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderProfileDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderProfileDraft>(value),
    );
  }
}

String _$providerProfileNotifierHash() =>
    r'ae75172f37a31567101df178a025cf76e5fce056';

abstract class _$ProviderProfileNotifier
    extends $Notifier<ProviderProfileDraft> {
  ProviderProfileDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProviderProfileDraft, ProviderProfileDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProviderProfileDraft, ProviderProfileDraft>,
              ProviderProfileDraft,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(providerStatus)
final providerStatusProvider = ProviderStatusProvider._();

final class ProviderStatusProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  ProviderStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerStatusHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return providerStatus(ref);
  }
}

String _$providerStatusHash() => r'd7fef391e55e2d547d0ef602f6c5415e34111e49';
