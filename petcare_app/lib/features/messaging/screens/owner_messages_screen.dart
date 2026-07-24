import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/messaging/data/mock_owner_messages.dart';
import 'package:petcare_app/features/messaging/widgets/messages_tab.dart';

// Tab Tin nhắn của chủ nuôi
class OwnerMessagesScreen extends StatelessWidget {
  const OwnerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MessagesTab(
      conversations: MockOwnerMessagesData.conversations,
      title: l10n.tinNhan,
      subtitle: l10n.troChuyenGanVoiDon,
      searchHint: l10n.timKiemTinNhan,
      emptyTitle: l10n.chuaCoTinNhan,
      emptyMessage: l10n.chuaCoTinNhanOwnerMoTa,
      lightHeader: true,
    );
  }
}
