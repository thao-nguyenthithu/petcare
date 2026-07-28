import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/address/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/features/messaging/data/conversation.dart';
import 'package:petcare_app/features/messaging/widgets/chat_app_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_input_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_locked.dart';
import 'package:petcare_app/features/messaging/widgets/chat_pets_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_system_chip.dart';
import 'package:petcare_app/features/messaging/widgets/message_bubble.dart';
import 'package:petcare_app/features/messaging/widgets/quick_reply_bar.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Tham số mở màn chat: hội thoại, vai người đang xem
class ChatArgs {
  const ChatArgs({required this.conversation, required this.isOwner});

  final Conversation conversation;
  final bool isOwner;
}

// Màn chi tiết trò chuyện
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.thread,
    required this.isOwner,
  });

  final Conversation conversation;
  final ChatThread thread;
  final bool isOwner;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  late final List<ChatMessage> _messages = List.of(widget.thread.messages);
  final _timers = <Timer>[];

  bool get _ended => widget.conversation.state == ConversationState.daKetThuc;

  // Đồng hồ đếm ngược
  bool get _dangDienRa =>
      widget.conversation.state == ConversationState.dangDienRa;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  String _now() {
    final d = DateTime.now();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // Mô phỏng vòng đời gửi tin (đang gửi -> đã gửi -> đã đọc)
  void _append(ChatMessage message) {
    setState(() => _messages.add(message));
    _simulateDelivery(_messages.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // Đang gửi -> (1.2s) đã gửi -> (1.5s) đã đọc
  void _simulateDelivery(int index) {
    _timers.add(
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(
          () => _messages[index] = _messages[index].copyWith(
            status: ChatSendStatus.sent,
          ),
        );
        _timers.add(
          Timer(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            setState(
              () => _messages[index] = _messages[index].copyWith(
                status: ChatSendStatus.read,
              ),
            );
          }),
        );
      }),
    );
  }

  void _sendText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    _append(
      ChatMessage(
        kind: ChatMessageKind.text,
        fromMe: true,
        text: text,
        timeLabel: _now(),
        status: ChatSendStatus.sending,
      ),
    );
  }

  void _sendQuickReply(String text) {
    _append(
      ChatMessage(
        kind: ChatMessageKind.text,
        fromMe: true,
        text: text,
        timeLabel: _now(),
        status: ChatSendStatus.sending,
      ),
    );
  }

  // Bấm thử lại để gửi tin nhắn bị lỗi
  void _retry(int index) {
    setState(
      () => _messages[index] = _messages[index].copyWith(
        status: ChatSendStatus.sending,
      ),
    );
    _simulateDelivery(index);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Chụp một ảnh bằng camera
  Future<void> _capturePhoto() async {
    final l10n = context.l10n;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file == null) return;
      await _appendImages([file]);
    } catch (_) {
      _snack(l10n.khongMoDuocAnh);
    }
  }

  // Chọn nhiều ảnh từ thư viện
  Future<void> _pickFromGallery() async {
    final l10n = context.l10n;
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (files.isEmpty) return;
      await _appendImages(files);
    } catch (_) {
      _snack(l10n.khongMoDuocAnh);
    }
  }

  Future<void> _appendImages(List<XFile> files) async {
    final bytes = <Uint8List>[];
    for (final file in files) {
      bytes.add(await file.readAsBytes());
    }
    if (!mounted) return;
    _append(
      ChatMessage(
        kind: ChatMessageKind.image,
        fromMe: true,
        images: bytes,
        timeLabel: _now(),
        status: ChatSendStatus.sending,
      ),
    );
  }

  // Mở màn bản đồ để chọn vị trí rồi gửi
  Future<void> _pickLocation() async {
    final result = await context.push<Object?>(AppRoutes.locationPicker);
    if (!mounted || result is! KetQuaViTri) return;
    final coord =
        '${result.viTri.latitude.toStringAsFixed(5)}, ${result.viTri.longitude.toStringAsFixed(5)}';
    _append(
      ChatMessage(
        kind: ChatMessageKind.location,
        fromMe: true,
        location: result.viTri,
        caption: result.moTa ?? coord,
        timeLabel: _now(),
        status: ChatSendStatus.sending,
      ),
    );
  }

  void _openAttachSheet() {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(l10n.chupAnh),
              onTap: () {
                Navigator.pop(sheetContext);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(l10n.chonTuThuVien),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(l10n.guiViTri),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Màn chi tiết trò chuyện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ChatAppBar(
            conversation: widget.conversation,
            countdown: _dangDienRa ? widget.thread.countdown : null,
          ),
          if (widget.conversation.nhieuBe)
            ChatPetsBar(conversation: widget.conversation),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
              ),
              // Chat khoá
              itemCount: _messages.length + (_ended ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.itemGap),
              itemBuilder: (context, i) {
                if (_ended && i == _messages.length) {
                  return ChatEndedNotice(
                    onHelpTap: () => baoDangPhatTrien(context),
                  );
                }
                final m = _messages[i];
                if (m.kind == ChatMessageKind.system) {
                  return ChatSystemChip(message: m);
                }
                return MessageBubble(
                  message: m,
                  onRetry: !_ended && m.status == ChatSendStatus.failed
                      ? () => _retry(i)
                      : null,
                );
              },
            ),
          ),
          if (_ended)
            const ChatResetFooter()
          else ...[
            QuickReplyBar(isOwner: widget.isOwner, onSelect: _sendQuickReply),
            const SizedBox(height: AppSpacing.labelGap),
            ChatInputBar(
              controller: _inputController,
              onSend: _sendText,
              onAttach: _openAttachSheet,
            ),
          ],
        ],
      ),
    );
  }
}
