import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/utils/vn_date.dart';

// Model tin nhắn nội dung bên trong một cuộc trò chuyện

// nội dung một dòng trong luồng chat
enum ChatMessageKind { system, text, image, location }

// Chip hệ thống và tin sự kiện của đơn; suKien là nhật ký việc đã xảy ra
enum ChatSystemKind { sessionStart, safety, suKien }

// Trạng thái gửi của tin do mình gửi
enum ChatSendStatus { sent, read, sending, failed }

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
    this.soAnhThem,
  });

  // Tin sự kiện của đơn; canGap cho tin có hệ quả tiền hoặc cần làm gấp
  const ChatMessage.suKien(
    String noiDung, {
    this.canGap = false,
    this.actionLabel,
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
      soAnhThem = null;

  // Chip nhắc giao dịch an toàn trong app
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
      soAnhThem = null;

  // Server đã chọn sẵn bản chữ theo vai người đọc, khỏi phân nhánh lại
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
      // Tin hệ thống không hiện giờ riêng: giờ đã ghép sẵn cuối câu
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
      soAnhThem: (json['soAnhThem'] as num?)?.toInt(),
    );
  }

  final String? id;
  final ChatMessageKind kind;
  final ChatSystemKind? systemKind;
  final bool fromMe;
  final String text;
  final String? timeLabel; // giờ hiển thị dưới bong bóng
  final ChatSendStatus? status; // trạng thái gửi

  final String? caption; // dòng mô tả dưới khối vị trí

  // URL http là ảnh đã lên server, đường dẫn thường là ảnh còn trên máy
  final List<String>? images;
  final LatLng? location; // toạ độ tin vị trí hiện bản đồ thu nhỏ
  final bool masked; // tin bị ẩn số điện thoại kèm cảnh báo
  final bool canGap; // tin sự kiện có hệ quả tiền hoặc cần làm gấp
  final String? actionLabel; // nhãn link, null là tin không dẫn đi đâu
  final int? soAnhThem; // số ảnh còn lại, phủ "+n" lên ô cuối của lô ảnh

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

  // Con trỏ xin trang tin cũ hơn; null là đã tới đầu luồng
  final String? truocTiep;
}
