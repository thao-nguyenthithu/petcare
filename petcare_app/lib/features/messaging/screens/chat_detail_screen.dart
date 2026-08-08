import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/features/messaging/providers/chat_thread_provider.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/messaging/widgets/chat_app_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_input_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_locked.dart';
import 'package:petcare_app/features/messaging/widgets/chat_pets_bar.dart';
import 'package:petcare_app/features/messaging/widgets/chat_system_chip.dart';
import 'package:petcare_app/features/messaging/widgets/chat_system_message.dart';
import 'package:petcare_app/features/messaging/widgets/message_bubble.dart';
import 'package:petcare_app/features/messaging/widgets/quick_reply_bar.dart';
import 'package:petcare_app/shared/data/conversation.dart';
import 'package:petcare_app/shared/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Tham số mở màn chat: hội thoại, vai người đang xem
class ChatArgs {
  const ChatArgs({required this.conversation, required this.isOwner});

  final Conversation conversation;
  final bool isOwner;
}

// Màn chi tiết trò chuyện
class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.isOwner,
  });

  final Conversation conversation;
  final bool isOwner;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  bool get _ended => widget.conversation.state == ConversationState.daKetThuc;

  bool get _dangDienRa =>
      widget.conversation.state == ConversationState.dangDienRa;

  LuongChat get _luong =>
      ref.read(luongChatProvider(widget.conversation.id).notifier);

  String get _id => widget.conversation.id;

  @override
  void initState() {
    super.initState();
    if (!widget.conversation.chuaDoc) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _danhDauDaDoc());
  }

  Future<void> _danhDauDaDoc() => widget.isOwner
      ? ref.read(hoiThoaiChuNuoiProvider.notifier).danhDauDaDoc(_id)
      : ref.read(hoiThoaiNguoiChamProvider.notifier).danhDauDaDoc(_id);

  void _tinCuoiCuaToi(String noiDung) {
    if (widget.isOwner) {
      ref.read(hoiThoaiChuNuoiProvider.notifier).capNhatTinCuoi(_id, noiDung);
    } else {
      ref.read(hoiThoaiNguoiChamProvider.notifier).capNhatTinCuoi(_id, noiDung);
    }
  }

  Future<void> _taiLaiDanhSach() => widget.isOwner
      ? ref.read(hoiThoaiChuNuoiProvider.notifier).taiLai()
      : ref.read(hoiThoaiNguoiChamProvider.notifier).taiLai();

  bool get _tinCuoiDaGui {
    final tin = ref.read(luongChatProvider(_id)).value?.messages.lastOrNull;
    return tin != null && tin.status != ChatSendStatus.failed;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _xuongDay() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _sendText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await _guiChu(text);
  }

  Future<void> _sendQuickReply(String text) => _guiChu(text);

  Future<void> _guiChu(String text) async {
    await _luong.guiChu(text);
    if (!mounted) return;
    if (_tinCuoiDaGui) _tinCuoiCuaToi(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _capturePhoto() async {
    final l10n = context.l10n;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file == null) return;
      await _guiAnh([file]);
    } catch (_) {
      _snack(l10n.khongMoDuocAnh);
    }
  }

  Future<void> _pickFromGallery() async {
    final l10n = context.l10n;
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (files.isEmpty) return;
      await _guiAnh(files);
    } catch (_) {
      _snack(l10n.khongMoDuocAnh);
    }
  }

  Future<void> _guiAnh(List<XFile> files) async {
    await _luong.guiAnh([for (final f in files) f.path]);
    if (!mounted) return;
    if (_tinCuoiDaGui) await _taiLaiDanhSach();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  Future<void> _pickLocation() async {
    final result = await context.push<Object?>(AppRoutes.locationPicker);
    if (!mounted || result is! KetQuaViTri) return;
    await _luong.guiViTri(
      lat: result.viTri.latitude,
      lng: result.viTri.longitude,
      moTa: result.moTa,
    );
    if (!mounted) return;
    if (_tinCuoiDaGui) await _taiLaiDanhSach();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
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

  @override
  Widget build(BuildContext context) {
    ref.listen(luongChatProvider(_id), (truoc, sau) {
      final cu = truoc?.value?.messages;
      final moi = sau.value?.messages;
      if (moi == null || moi.isEmpty) return;
      if (cu == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _xuongDay());
        return;
      }
      if (moi.length <= cu.length || identical(moi.last, cu.last)) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      if (!moi.last.fromMe) _danhDauDaDoc();
    });
    return _than(ref.watch(luongChatProvider(_id)));
  }

  Widget _than(AsyncValue<ChatThread> luong) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ChatAppBar(
            conversation: widget.conversation,
            isOwner: widget.isOwner,
            countdown: _dangDienRa ? luong.value?.countdown : null,
          ),
          if (widget.conversation.nhieuBe)
            ChatPetsBar(conversation: widget.conversation),
          Expanded(
            child: luong.when(
              loading: () => const AppSkeletonList(soThe: 5, caoThe: 56),
              error: (loi, _) => AppNetworkError(
                onRetry: () =>
                    ref.invalidate(luongChatProvider(widget.conversation.id)),
              ),
              data: (thread) => _DanhSachTin(
                messages: thread.messages,
                controller: _scrollController,
                ended: _ended,
                onRetry: _luong.guiLai,
              ),
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

// Danh sách tin trong khung chat
class _DanhSachTin extends StatelessWidget {
  const _DanhSachTin({
    required this.messages,
    required this.controller,
    required this.ended,
    required this.onRetry,
  });

  final List<ChatMessage> messages;
  final ScrollController controller;
  final bool ended;
  final ValueChanged<int> onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
      ),
      itemCount: messages.length + (ended ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (context, i) {
        if (ended && i == messages.length) {
          return ChatEndedNotice(onHelpTap: () => baoDangPhatTrien(context));
        }
        final m = messages[i];
        if (m.kind == ChatMessageKind.system) {
          return m.systemKind == ChatSystemKind.suKien
              ? ChatSystemMessage(message: m)
              : ChatSystemChip(message: m);
        }
        return MessageBubble(
          message: m,
          onRetry: !ended && m.status == ChatSendStatus.failed
              ? () => onRetry(i)
              : null,
        );
      },
    );
  }
}
