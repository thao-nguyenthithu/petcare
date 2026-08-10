import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/utils/vn_date.dart';

enum ChatMessageKind { system, text, image, location }

enum ChatSystemKind { sessionStart, safety, suKien }

enum ChatSendStatus { sent, read, sending, failed }

// Đích của nút trong tin hệ thống, máy chủ gửi kèm mã chứ không chỉ nhãn chữ
enum MaHanhDongTin {
  chiDuong,
  viTriTrucTiep,
  anhMinhChung,
  xacNhanHoanThanh,
  vi,
}

MaHanhDongTin? _maHanhDong(String? ma) => switch (ma) {
  'chiDuong' => MaHanhDongTin.chiDuong,
  'viTriTrucTiep' => MaHanhDongTin.viTriTrucTiep,
  'anhMinhChung' => MaHanhDongTin.anhMinhChung,
  'xacNhanHoanThanh' => MaHanhDongTin.xacNhanHoanThanh,
  'vi' => MaHanhDongTin.vi,
  _ => null,
};

// Một dòng trong luồng chat
class ChatMessage {
  const ChatMessage({
    required this.kind,
    this.id,
    this.systemKind,
    this.fromMe = false,
    this.text = '',
    this.timeLabel,
    this.status,
    this.caption,
    this.images,
    this.location,
    this.masked = false,
    this.canGap = false,
    this.actionLabel,
    this.actionCode,
    this.soAnhThem,
  });

  const ChatMessage.suKien(
    String noiDung, {
    this.canGap = false,
    this.actionLabel,
    this.actionCode,
    this.id,
  }) : kind = ChatMessageKind.system,
       systemKind = ChatSystemKind.suKien,
       fromMe = false,
       text = noiDung,
       timeLabel = null,
       status = null,
       caption = null,
       images = null,
       location = null,
       masked = false,
       soAnhThem = null;

  // Chip mở phiên
  const ChatMessage.session(String gio)
    : kind = ChatMessageKind.system,
      systemKind = ChatSystemKind.sessionStart,
      id = null,
      fromMe = false,
      text = gio,
      timeLabel = null,
      status = null,
      caption = null,
      images = null,
      location = null,
      masked = false,
      canGap = false,
      actionLabel = null,
      actionCode = null,
      soAnhThem = null;

  const ChatMessage.safety()
    : kind = ChatMessageKind.system,
      systemKind = ChatSystemKind.safety,
      id = null,
      fromMe = false,
      text = '',
      timeLabel = null,
      status = null,
      caption = null,
      images = null,
      location = null,
      masked = false,
      canGap = false,
      actionLabel = null,
      actionCode = null,
      soAnhThem = null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final kieu = json['kind'] as String? ?? 'TEXT';
    final laHeThong = kieu == 'SYSTEM';
    final anh = [
      for (final e in (json['images'] as List? ?? const [])) e as String,
    ];
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    final tao = docMocVn(json['createdAt'] as String?) ?? nowVn();
    return ChatMessage(
      id: json['id'] as String?,
      kind: switch (kieu) {
        'SYSTEM' => ChatMessageKind.system,
        'IMAGE' => ChatMessageKind.image,
        'LOCATION' => ChatMessageKind.location,
        _ => ChatMessageKind.text,
      },
      systemKind: laHeThong ? ChatSystemKind.suKien : null,
      fromMe: json['fromMe'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      timeLabel: laHeThong ? null : _gio(tao),
      status: (json['fromMe'] as bool? ?? false)
          ? ((json['isRead'] as bool? ?? false)
                ? ChatSendStatus.read
                : ChatSendStatus.sent)
          : null,
      caption: json['caption'] as String?,
      images: anh.isEmpty ? null : anh,
      location: lat != null && lng != null ? LatLng(lat, lng) : null,
      masked: json['masked'] as bool? ?? false,
      canGap: json['canGap'] as bool? ?? false,
      actionLabel: json['actionLabel'] as String?,
      actionCode: _maHanhDong(json['actionCode'] as String?),
      soAnhThem: (json['soAnhThem'] as num?)?.toInt(),
    );
  }

  final String? id;
  final ChatMessageKind kind;
  final ChatSystemKind? systemKind;
  final bool fromMe;
  final String text;
  final String? timeLabel;
  final ChatSendStatus? status;

  final String? caption;
  final List<String>? images;
  final LatLng? location;
  final bool masked;
  final bool canGap;
  final String? actionLabel;
  final MaHanhDongTin? actionCode;
  final int? soAnhThem;

  ChatMessage copyWith({ChatSendStatus? status}) => ChatMessage(
    id: id,
    kind: kind,
    systemKind: systemKind,
    fromMe: fromMe,
    text: text,
    timeLabel: timeLabel,
    status: status ?? this.status,
    caption: caption,
    images: images,
    location: location,
    masked: masked,
    canGap: canGap,
    actionLabel: actionLabel,
    actionCode: actionCode,
    soAnhThem: soAnhThem,
  );

  static String _gio(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// Toàn bộ một cuộc trò chuyện đang mở.
class ChatThread {
  const ChatThread({required this.messages, this.countdown, this.truocTiep});

  final List<ChatMessage> messages;
  final String? countdown;
  final String? truocTiep;
}
