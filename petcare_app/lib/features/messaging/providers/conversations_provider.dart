import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/messaging/data/conversation.dart';
import 'package:petcare_app/features/messaging/data/mock_owner_messages.dart';
import 'package:petcare_app/features/messaging/data/mock_sitter_messages.dart';

// State danh sách hội thoại
class ConversationsNotifier extends Notifier<List<Conversation>> {
  ConversationsNotifier(this._seed);

  final List<Conversation> _seed;

  @override
  List<Conversation> build() => List.of(_seed);

  void danhDauDaDoc(String id) {
    state = [
      for (final c in state)
        if (c.id == id && c.chuaDoc) c.copyWith(unreadCount: 0) else c,
    ];
  }
}

// Hội thoại của chủ nuôi
final ownerConversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      () => ConversationsNotifier(MockOwnerMessagesData.conversations),
    );

// Hội thoại của người cung cấp
final sitterConversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      () => ConversationsNotifier(MockSitterMessagesData.conversations),
    );

// Tổng số tin chưa đọc, badge trên tab Tin nhắn
final ownerUnreadCountProvider = Provider<int>(
  (ref) => ref
      .watch(ownerConversationsProvider)
      .fold(0, (tong, c) => tong + c.unreadCount),
);

final sitterUnreadCountProvider = Provider<int>(
  (ref) => ref
      .watch(sitterConversationsProvider)
      .fold(0, (tong, c) => tong + c.unreadCount),
);
