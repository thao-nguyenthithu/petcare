import 'package:petcare_app/shared/data/pet_brief.dart';

// Model cuộc trò chuyện chat
// Trạng thái vòng đời chat của đơn
enum ConversationState { sapToi, dangDienRa, choXacNhan, daKetThuc }

enum ServiceKind { datDiDao, trongGiu, tamTia }

// Một loại dịch vụ cho 1..n bé của chủ nuôi
class Conversation {
  const Conversation({
    required this.id,
    required this.partnerName,
    required this.partnerAvatar,
    required this.serviceName,
    required this.pets,
    required this.serviceType,
    required this.bookingCode,
    required this.state,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.fromMe,
    this.remainingMinutes,
  });

  const Conversation.forOrder({
    required this.id,
    required this.partnerName,
    required this.serviceName,
    required this.pets,
    required this.serviceType,
    required this.bookingCode,
    required this.state,
    this.partnerAvatar = '',
    this.remainingMinutes,
  }) : lastMessage = '',
       timeLabel = '',
       unreadCount = 0,
       fromMe = false;

  final String id;
  final String partnerName;
  final String partnerAvatar;
  final String serviceName;
  final List<PetBrief> pets;
  final ServiceKind serviceType;
  final String bookingCode;
  final ConversationState state;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool fromMe;

  // Số phút còn lại của phiên đang chạy
  final int? remainingMinutes;

  bool get chuaDoc => unreadCount > 0;

  bool get daKetThuc => state == ConversationState.daKetThuc;

  bool get nhieuBe => pets.length > 1;

  // Phiên đang chạy và còn thời gian để đếm ngược trên nhãn trạng thái
  bool get dangChay =>
      state == ConversationState.dangDienRa && (remainingMinutes ?? 0) > 0;

  // Mô tả các bé
  String get moTaBe => PetBrief.moTa(pets);

  String get serviceContext =>
      pets.isEmpty ? serviceName : '$serviceName · $moTaBe';

  Conversation copyWith({int? unreadCount}) => Conversation(
    id: id,
    partnerName: partnerName,
    partnerAvatar: partnerAvatar,
    serviceName: serviceName,
    pets: pets,
    serviceType: serviceType,
    bookingCode: bookingCode,
    state: state,
    lastMessage: lastMessage,
    timeLabel: timeLabel,
    unreadCount: unreadCount ?? this.unreadCount,
    fromMe: fromMe,
    remainingMinutes: remainingMinutes,
  );

  bool matches(String keyword) {
    final kw = keyword.toLowerCase();
    return partnerName.toLowerCase().contains(kw) ||
        serviceName.toLowerCase().contains(kw) ||
        pets.any((p) => p.name.toLowerCase().contains(kw)) ||
        bookingCode.toLowerCase().contains(kw);
  }
}
