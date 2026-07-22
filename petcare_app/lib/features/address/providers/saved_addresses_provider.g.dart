// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_addresses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedAddresses)
final savedAddressesProvider = SavedAddressesProvider._();

final class SavedAddressesProvider
    extends $AsyncNotifierProvider<SavedAddresses, List<SavedAddress>> {
  SavedAddressesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedAddressesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedAddressesHash();

  @$internal
  @override
  SavedAddresses create() => SavedAddresses();
}

String _$savedAddressesHash() => r'74bc56f511eae1d225300d8ab352afe4cae876d9';

abstract class _$SavedAddresses extends $AsyncNotifier<List<SavedAddress>> {
  FutureOr<List<SavedAddress>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedAddress>>, List<SavedAddress>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedAddress>>, List<SavedAddress>>,
              AsyncValue<List<SavedAddress>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
