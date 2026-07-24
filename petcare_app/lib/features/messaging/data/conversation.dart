// Model cuộc trò chuyện chat
// Trạng thái vòng đời chat của đơn
enum ConversationState { sapToi, dangDienRa, daHoanTat, daKetThuc }

enum ServiceKind { datDiDao, trongGiu, tamTia }

// Một cuộc trò chuyện giữa hai bên
class Conversation {
  const Conversation({
    required this.id,
    required this.partnerName,
    required this.partnerAvatar,
    required this.serviceContext,
    required this.serviceType,
    required this.bookingCode,
    required this.state,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.fromMe,
  });

  final String id;
  final String partnerName;
  final String partnerAvatar;
  final String serviceContext;
  final ServiceKind serviceType;
  final String bookingCode;
  final ConversationState state;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool fromMe;

  bool get chuaDoc => unreadCount > 0;

  bool get daKetThuc => state == ConversationState.daKetThuc;

  bool matches(String keyword) {
    final kw = keyword.toLowerCase();
    return partnerName.toLowerCase().contains(kw) ||
        serviceContext.toLowerCase().contains(kw) ||
        bookingCode.toLowerCase().contains(kw);
  }
}
