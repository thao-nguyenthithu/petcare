import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

// Model tin nhắn nội dung bên trong một cuộc trò chuyện

// nội dung một dòng trong luồng chat
enum ChatMessageKind { system, text, image, location }

// Chip hệ thống mở phiên, nhắc giao dịch an toàn
enum ChatSystemKind { sessionStart, safety }

// Trạng thái gửi của tin do mình gửi
enum ChatSendStatus { sent, read, sending, failed }

// Một dòng trong luồng chat
class ChatMessage {
  const ChatMessage({
    required this.kind,
    this.systemKind,
    this.fromMe = false,
    this.text = '',
    this.timeLabel,
    this.status,
    this.caption,
    this.images,
    this.location,
    this.masked = false,
  });

  // Chip mở phiên
  const ChatMessage.session(String gio)
    : kind = ChatMessageKind.system,
      systemKind = ChatSystemKind.sessionStart,
      fromMe = false,
      text = gio,
      timeLabel = null,
      status = null,
      caption = null,
      images = null,
      location = null,
      masked = false;

  // Chip nhắc giao dịch an toàn trong app
  const ChatMessage.safety()
    : kind = ChatMessageKind.system,
      systemKind = ChatSystemKind.safety,
      fromMe = false,
      text = '',
      timeLabel = null,
      status = null,
      caption = null,
      images = null,
      location = null,
      masked = false;

  final ChatMessageKind kind;
  final ChatSystemKind? systemKind;
  final bool fromMe;
  final String text;
  final String? timeLabel; // giờ hiển thị dưới bong bóng
  final ChatSendStatus? status; // trạng thái gửi
  final String? caption; // dòng mô tả dưới khối vị trí
  final List<Uint8List>? images;
  final LatLng? location; // toạ độ tin vị trí hiện bản đồ thu nhỏ
  final bool masked; // tin bị ẩn số điện thoại kèm cảnh báo

  ChatMessage copyWith({ChatSendStatus? status}) => ChatMessage(
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
  );
}

// Toàn bộ một cuộc trò chuyện đang mở.
class ChatThread {
  const ChatThread({required this.messages, this.countdown});

  final List<ChatMessage> messages;
  final String? countdown;
}
