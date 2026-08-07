// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LichSuTim)
final lichSuTimProvider = LichSuTimProvider._();

final class LichSuTimProvider
    extends $AsyncNotifierProvider<LichSuTim, List<String>> {
  LichSuTimProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lichSuTimProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lichSuTimHash();

  @$internal
  @override
  LichSuTim create() => LichSuTim();
}

String _$lichSuTimHash() => r'f6f27790dba821f1a7be0f921da7fa3f6d15c16c';

abstract class _$LichSuTim extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
