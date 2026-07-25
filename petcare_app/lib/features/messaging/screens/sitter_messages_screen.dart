import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/messaging/widgets/messages_tab.dart';

// Tab Tin nhắn của ncc
class SitterMessagesScreen extends ConsumerWidget {
  const SitterMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return MessagesTab(
      conversations: ref.watch(sitterConversationsProvider),
      title: l10n.tinNhan,
      subtitle: l10n.troDoiVoiChuNuoi,
      searchHint: l10n.timKiemTinNhan,
      emptyTitle: l10n.chuaCoTinNhan,
      emptyMessage: l10n.chuaCoTinNhanMoTa,
      onOpen: (c) =>
          ref.read(sitterConversationsProvider.notifier).danhDauDaDoc(c.id),
    );
  }
}
