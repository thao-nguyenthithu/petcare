// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LuongChat)
final luongChatProvider = LuongChatFamily._();

final class LuongChatProvider
    extends $AsyncNotifierProvider<LuongChat, ChatThread> {
  LuongChatProvider._({
    required LuongChatFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'luongChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$luongChatHash();

  @override
  String toString() {
    return r'luongChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LuongChat create() => LuongChat();

  @override
  bool operator ==(Object other) {
    return other is LuongChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$luongChatHash() => r'a80277968841a99b40fd5770b584d405e6429d83';

final class LuongChatFamily extends $Family
    with
        $ClassFamilyOverride<
          LuongChat,
          AsyncValue<ChatThread>,
          ChatThread,
          FutureOr<ChatThread>,
          String
        > {
  LuongChatFamily._()
    : super(
        retry: null,
        name: r'luongChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LuongChatProvider call(String conversationId) =>
      LuongChatProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'luongChatProvider';
}

abstract class _$LuongChat extends $AsyncNotifier<ChatThread> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  FutureOr<ChatThread> build(String conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ChatThread>, ChatThread>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChatThread>, ChatThread>,
              AsyncValue<ChatThread>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
