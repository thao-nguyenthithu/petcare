import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
export 'package:petcare_app/shared/data/sitter_services.dart' show ServiceType;

// Trạng thái vòng đời chat của đơn
enum ConversationState { sapToi, dangDienRa, choXacNhan, daKetThuc }

const int _trongNgay = 24 * 60;
const int _quaXa = 1 << 30;

class Conversation {
  const Conversation({
    required this.id,
    this.bookingId,
    this.sitterId,
    required this.partnerName,
    required this.partnerAvatar,
    required this.serviceName,
    required this.pets,
    required this.serviceType,
    required this.bookingCode,
    required this.state,
    required this.lastMessage,
    this.timeLabel = '',
    this.lastMessageAt,
    required this.unreadCount,
    required this.fromMe,
    this.remainingMinutes,
  });

  const Conversation.forOrder({
    required this.id,
    this.bookingId,
    this.sitterId,
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
       lastMessageAt = null,
       unreadCount = 0,
       fromMe = false;

  // Nhãn thời gian chỉ nhận mốc thật, widget tự đặt chữ
  factory Conversation.fromJson(Map<String, dynamic> json) {
    final moc = json['lastMessageAt'] as String?;
    return Conversation(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      sitterId: json['sitterId'] as String?,
      partnerName: json['partnerName'] as String? ?? '',
      partnerAvatar: json['partnerAvatar'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      pets: [
        for (final e in (json['pets'] as List? ?? const []))
          PetBrief(
            name: (e as Map)['name'] as String? ?? '',
            species: e['species'] as String? ?? '',
            avatar: e['avatarUrl'] as String?,
          ),
      ],
      serviceType: switch (json['serviceType'] as String?) {
        'BOARDING' => ServiceType.boarding,
        'GROOMING' => ServiceType.grooming,
        _ => ServiceType.walking,
      },
      bookingCode: json['bookingCode'] as String? ?? '',
      state: switch (json['state'] as String?) {
        'dangDienRa' => ConversationState.dangDienRa,
        'choXacNhan' => ConversationState.choXacNhan,
        'daKetThuc' => ConversationState.daKetThuc,
        _ => ConversationState.sapToi,
      },
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: docMocVn(moc),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      fromMe: json['fromMe'] as bool? ?? false,
      remainingMinutes: (json['remainingMinutes'] as num?)?.toInt(),
    );
  }

  final String id;

  final String? bookingId;
  final String? sitterId;
  final String partnerName;
  final String partnerAvatar;
  final String serviceName;
  final List<PetBrief> pets;
  final ServiceType serviceType;
  final String bookingCode;
  final ConversationState state;
  final String lastMessage;
  final String timeLabel;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool fromMe;
  // Số phút còn lại của phiên đang chạy
  final int? remainingMinutes;

  bool get chuaDoc => unreadCount > 0;
  bool get daKetThuc => state == ConversationState.daKetThuc;
  bool get nhieuBe => pets.length > 1;
  bool get dangChay =>
      state == ConversationState.dangDienRa && (remainingMinutes ?? 0) > 0;

  bool get theoNgay => serviceType == ServiceType.boarding;

  bool get sapToiGan =>
      state == ConversationState.sapToi &&
      (remainingMinutes ?? _quaXa) <= _trongNgay;

  bool get choChuNuoiChot =>
      state == ConversationState.choXacNhan && (remainingMinutes ?? 0) > 0;

  // Mô tả các bé
  String get moTaBe => PetBrief.moTa(pets);

  String get serviceContext =>
      pets.isEmpty ? serviceName : '$serviceName · $moTaBe';

  Conversation copyWith({
    int? unreadCount,
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? fromMe,
  }) => Conversation(
    id: id,
    bookingId: bookingId,
    sitterId: sitterId,
    partnerName: partnerName,
    partnerAvatar: partnerAvatar,
    serviceName: serviceName,
    pets: pets,
    serviceType: serviceType,
    bookingCode: bookingCode,
    state: state,
    lastMessage: lastMessage ?? this.lastMessage,
    timeLabel: timeLabel,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    fromMe: fromMe ?? this.fromMe,
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
