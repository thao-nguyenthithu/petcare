import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/text_normalize.dart';

const int _nguongTimKiem = 10;

// Bảng chọn một trong danh sách
Future<T?> showChoiceSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T) labelOf,
  T? selected,
}) {
  final coTimKiem = items.length > _nguongTimKiem;
  var tuKhoa = '';
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, doiTrangThai) {
        final mq = MediaQuery.of(context);
        final ketQua = tuKhoa.isEmpty
            ? items
            : items
                  .where(
                    (muc) => boDau(
                      labelOf(muc).toLowerCase(),
                    ).contains(boDau(tuKhoa)),
                  )
                  .toList();
        return Padding(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (mq.size.height - mq.viewInsets.bottom) * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (coTimKiem)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      autofocus: true,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.timKiem,
                        hintStyle: AppTextStyles.caption,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius14,
                          ),
                        ),
                      ),
                      onChanged: (giaTri) => doiTrangThai(
                        () => tuKhoa = giaTri.trim().toLowerCase(),
                      ),
                    ),
                  ),
                Flexible(
                  child: ketQua.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            context.l10n.khongTimThayKetQua,
                            style: AppTextStyles.caption,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: ketQua.length,
                          itemBuilder: (_, viTri) {
                            final muc = ketQua[viTri];
                            return ListTile(
                              title: Text(
                                labelOf(muc),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: muc == selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.primaryColor,
                                    )
                                  : null,
                              onTap: () => Navigator.pop(sheetContext, muc),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
