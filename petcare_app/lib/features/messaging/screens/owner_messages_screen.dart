import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/messaging/widgets/messages_tab.dart';

// Tab Tin nhắn của chủ nuôi
class OwnerMessagesScreen extends ConsumerWidget {
  const OwnerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return MessagesTab(
      conversations: ref.watch(ownerConversationsProvider),
      title: l10n.tinNhan,
      subtitle: l10n.troChuyenGanVoiDon,
      searchHint: l10n.timKiemTinNhan,
      emptyTitle: l10n.chuaCoTinNhan,
      emptyMessage: l10n.chuaCoTinNhanOwnerMoTa,
      lightHeader: true,
      onOpen: (c) =>
          ref.read(ownerConversationsProvider.notifier).danhDauDaDoc(c.id),
    );
  }
}
