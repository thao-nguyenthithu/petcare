import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/features/messaging/services/chat_socket_service.dart';
import 'package:petcare_app/features/messaging/services/messaging_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_thread_provider.g.dart';

// Luồng tin của một hội thoại; không keepAlive vì rời màn chat là đóng socket
@riverpod
class LuongChat extends _$LuongChat {
  final _service = MessagingApiService();
  ChatSocketService? _socket;

  @override
  Future<ChatThread> build(String conversationId) async {
    ref.onDispose(() => _socket?.dong());
    final trang = await _service.tinNhan(conversationId);
    await _moSocket(conversationId);
    return ChatThread(messages: trang.items, truocTiep: trang.truocTiep);
  }

  Future<void> _moSocket(String conversationId) async {
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty) return;
    final socket = ChatSocketService(serverGoc: serverGoc, token: token);
    _socket = socket;
    socket.tinMoi.listen(_nhanTin);
    socket.ketNoi(conversationId: conversationId);
  }

  // Bỏ qua tin của CHÍNH MÌNH, bản lạc quan đã nằm sẵn nên nhận là đúp
  void _nhanTin(ChatMessage tin) {
    if (tin.fromMe) return;
    final cu = state.value;
    if (cu == null) return;
    if (tin.id != null && cu.messages.any((c) => c.id == tin.id)) return;
    state = AsyncData(
      ChatThread(
        messages: [...cu.messages, tin],
        countdown: cu.countdown,
        truocTiep: cu.truocTiep,
      ),
    );
  }

  // Cuộn ngược lên đầu luồng, nối trang cũ vào TRƯỚC danh sách đang hiện
  Future<void> taiThem() async {
    final cu = state.value;
    if (cu?.truocTiep == null) return;
    final trang = await _service.tinNhan(conversationId, truoc: cu!.truocTiep);
    state = AsyncData(
      ChatThread(
        messages: [...trang.items, ...cu.messages],
        countdown: cu.countdown,
        truocTiep: trang.truocTiep,
      ),
    );
  }

  // Hiện LẠC QUAN ngay, chờ mạng mới hiện là cảm giác đơ
  Future<void> guiChu(String noiDung) async {
    await _gui(
      ChatMessage(
        kind: ChatMessageKind.text,
        fromMe: true,
        text: noiDung,
        status: ChatSendStatus.sending,
      ),
      () => _service.guiChu(conversationId, noiDung),
    );
  }

  Future<void> guiViTri({
    required double lat,
    required double lng,
    String? moTa,
  }) async {
    await _gui(
      ChatMessage(
        kind: ChatMessageKind.location,
        fromMe: true,
        caption: moTa,
        status: ChatSendStatus.sending,
      ),
      () => _service.guiViTri(conversationId, lat: lat, lng: lng, moTa: moTa),
    );
  }

  Future<void> guiAnh(List<String> duongDan, {String? ghiChu}) async {
    await _gui(
      ChatMessage(
        kind: ChatMessageKind.image,
        fromMe: true,
        // Hiện tạm từ đường dẫn trên máy cho tới khi server trả URL
        images: duongDan,
        caption: ghiChu,
        status: ChatSendStatus.sending,
      ),
      () => _service.guiAnh(conversationId, duongDan, ghiChu: ghiChu),
    );
  }

  Future<void> _gui(
    ChatMessage tamThoi,
    Future<ChatMessage> Function() goiApi,
  ) async {
    final cu = state.value;
    if (cu == null) return;
    final viTri = cu.messages.length;
    state = AsyncData(
      ChatThread(
        messages: [...cu.messages, tamThoi],
        countdown: cu.countdown,
        truocTiep: cu.truocTiep,
      ),
    );
    try {
      final that = await goiApi();
      _thay(viTri, that);
    } catch (_) {
      // Xoá tin hỏng là mất nội dung vừa gõ, nút Thử lại không còn gì để gửi
      _thay(viTri, tamThoi.copyWith(status: ChatSendStatus.failed));
    }
  }

  void _thay(int viTri, ChatMessage tin) {
    final cu = state.value;
    if (cu == null || viTri >= cu.messages.length) return;
    final ds = [...cu.messages];
    ds[viTri] = tin;
    state = AsyncData(
      ChatThread(
        messages: ds,
        countdown: cu.countdown,
        truocTiep: cu.truocTiep,
      ),
    );
  }

  // Gửi lại một tin hỏng
  Future<void> guiLai(int viTri) async {
    final tin = state.value?.messages[viTri];
    if (tin == null) return;
    _thay(viTri, tin.copyWith(status: ChatSendStatus.sending));
    try {
      final that = tin.kind == ChatMessageKind.image
          ? await _service.guiAnh(
              conversationId,
              tin.images ?? const [],
              ghiChu: tin.caption,
            )
          : await _service.guiChu(conversationId, tin.text);
      _thay(viTri, that);
    } catch (_) {
      _thay(viTri, tin.copyWith(status: ChatSendStatus.failed));
    }
  }
}
