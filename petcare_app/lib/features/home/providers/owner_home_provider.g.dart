// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrangChuCuaToi)
final trangChuCuaToiProvider = TrangChuCuaToiProvider._();

final class TrangChuCuaToiProvider
    extends $AsyncNotifierProvider<TrangChuCuaToi, TrangChuChuNuoi> {
  TrangChuCuaToiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trangChuCuaToiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trangChuCuaToiHash();

  @$internal
  @override
  TrangChuCuaToi create() => TrangChuCuaToi();
}

String _$trangChuCuaToiHash() => r'57d16e20795ea6442ed039a83fd2921b469a001e';

abstract class _$TrangChuCuaToi extends $AsyncNotifier<TrangChuChuNuoi> {
  FutureOr<TrangChuChuNuoi> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrangChuChuNuoi>, TrangChuChuNuoi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrangChuChuNuoi>, TrangChuChuNuoi>,
              AsyncValue<TrangChuChuNuoi>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
