import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/shared/data/conversation.dart';

// `truocTiep` là con trỏ thời gian, null nghĩa là đã tới đầu luồng
typedef TrangTin = ({List<ChatMessage> items, String? truocTiep});

class MessagingApiService {
  // Gửi kèm vai đọc chứ không để server đoán, hai vai hai danh sách
  static String _vai(bool laChuNuoi) => laChuNuoi ? 'OWNER' : 'PROVIDER';

  Future<List<Conversation>> danhSach({required bool laChuNuoi}) async {
    final res = await apiClient.get(
      '/conversations',
      queryParameters: {'vai': _vai(laChuNuoi)},
    );
    return [
      for (final e in res.data as List)
        Conversation.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  }

  // Màn chi tiết chỉ cầm id đơn; chưa ai nhắn thì server tự mở hội thoại
  Future<Conversation?> theoDon(
    String bookingId, {
    required bool laChuNuoi,
  }) async {
    final res = await apiClient.get(
      '/conversations/by-booking/$bookingId',
      queryParameters: {'vai': _vai(laChuNuoi)},
    );
    final data = res.data;
    if (data == null || data is! Map) return null;
    return Conversation.fromJson(Map<String, dynamic>.from(data));
  }

  Future<int> soChuaDoc({required bool laChuNuoi}) async {
    final res = await apiClient.get(
      '/conversations/unread-count',
      queryParameters: {'vai': _vai(laChuNuoi)},
    );
    return (Map<String, dynamic>.from(res.data as Map)['total'] as int?) ?? 0;
  }

  Future<TrangTin> tinNhan(String conversationId, {String? truoc}) async {
    final res = await apiClient.get(
      '/conversations/$conversationId/messages',
      queryParameters: {'truoc': ?truoc},
    );
    final map = Map<String, dynamic>.from(res.data as Map);
    return (
      items: [
        for (final e in map['items'] as List)
          ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      truocTiep: map['truocTiep'] as String?,
    );
  }

  Future<ChatMessage> guiChu(String conversationId, String noiDung) async {
    final res = await apiClient.post(
      '/conversations/$conversationId/messages',
      data: {'text': noiDung},
    );
    return _docTin(res.data);
  }

  Future<ChatMessage> guiViTri(
    String conversationId, {
    required double lat,
    required double lng,
    String? moTa,
  }) async {
    final res = await apiClient.post(
      '/conversations/$conversationId/messages',
      data: {'lat': lat, 'lng': lng, 'caption': ?moTa},
    );
    return _docTin(res.data);
  }

  // Multipart chứ không base64, nhét vào JSON là phình thêm một phần ba
  Future<ChatMessage> guiAnh(
    String conversationId,
    List<String> duongDan, {
    String? ghiChu,
  }) async {
    final form = FormData();
    for (final path in duongDan) {
      form.files.add(MapEntry('photos', await MultipartFile.fromFile(path)));
    }
    if (ghiChu != null) form.fields.add(MapEntry('caption', ghiChu));
    final res = await apiClient.post(
      '/conversations/$conversationId/photos',
      data: form,
    );
    return _docTin(res.data);
  }

  Future<void> danhDauDaDoc(String conversationId) =>
      apiClient.post('/conversations/$conversationId/read');

  ChatMessage _docTin(Object? data) =>
      ChatMessage.fromJson(Map<String, dynamic>.from(data as Map));
}
