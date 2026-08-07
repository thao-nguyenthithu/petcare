// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sitter_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrangChuNguoiCham)
final trangChuNguoiChamProvider = TrangChuNguoiChamProvider._();

final class TrangChuNguoiChamProvider
    extends $AsyncNotifierProvider<TrangChuNguoiCham, SitterDashboard> {
  TrangChuNguoiChamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trangChuNguoiChamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trangChuNguoiChamHash();

  @$internal
  @override
  TrangChuNguoiCham create() => TrangChuNguoiCham();
}

String _$trangChuNguoiChamHash() => r'9e586b65fdd3e9783ea88ef69269230e51e9da9b';

abstract class _$TrangChuNguoiCham extends $AsyncNotifier<SitterDashboard> {
  FutureOr<SitterDashboard> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SitterDashboard>, SitterDashboard>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SitterDashboard>, SitterDashboard>,
              AsyncValue<SitterDashboard>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
