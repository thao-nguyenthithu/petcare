// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_pets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyPets)
final myPetsProvider = MyPetsProvider._();

final class MyPetsProvider extends $AsyncNotifierProvider<MyPets, List<Pet>> {
  MyPetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPetsHash();

  @$internal
  @override
  MyPets create() => MyPets();
}

String _$myPetsHash() => r'56fdd448b1104fef752b1faeab967d7f4d834d82';

abstract class _$MyPets extends $AsyncNotifier<List<Pet>> {
  FutureOr<List<Pet>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Pet>>, List<Pet>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Pet>>, List<Pet>>,
              AsyncValue<List<Pet>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(petTheoId)
final petTheoIdProvider = PetTheoIdFamily._();

final class PetTheoIdProvider extends $FunctionalProvider<Pet?, Pet?, Pet?>
    with $Provider<Pet?> {
  PetTheoIdProvider._({
    required PetTheoIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'petTheoIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$petTheoIdHash();

  @override
  String toString() {
    return r'petTheoIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Pet?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Pet? create(Ref ref) {
    final argument = this.argument as String;
    return petTheoId(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Pet? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Pet?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PetTheoIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$petTheoIdHash() => r'3854223729ec3f26e119fa9d70caed5d5d0a4bc1';

final class PetTheoIdFamily extends $Family
    with $FunctionalFamilyOverride<Pet?, String> {
  PetTheoIdFamily._()
    : super(
        retry: null,
        name: r'petTheoIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PetTheoIdProvider call(String id) =>
      PetTheoIdProvider._(argument: id, from: this);

  @override
  String toString() => r'petTheoIdProvider';
}
