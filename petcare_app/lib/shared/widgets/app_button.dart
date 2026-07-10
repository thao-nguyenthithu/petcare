import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

/// Nút chính full-width. Truyền MỘT trong hai:
/// - onTap: hành động tức thời (điều hướng...) — không có trạng thái chờ
/// - onTapAsync: hành động cần chờ (gọi API...) — trong lúc chạy sẽ phủ
///   loading toàn màn hình VÀ nút tự đổi sang màu disabled cho tới khi xong
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Future<void> Function()? onTapAsync;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.onTapAsync,
    this.height = 54,
  }) : assert(
         (onTap == null) != (onTapAsync == null),
         'Truyền đúng một trong hai: onTap hoặc onTapAsync',
       );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isLoading = false;

  Future<void> _runAsyncTap() async {
    setState(() => _isLoading = true);
    try {
      await showAppLoading(context, widget.onTapAsync!);
    } finally {
      // Trang có thể đã bị đóng trong lúc chờ — chỉ setState khi còn sống
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: FilledButton(
        // Đang chờ: onPressed null để nút nhận màu disabled từ AppTheme
        onPressed: _isLoading
            ? null
            : (widget.onTapAsync != null ? _runAsyncTap : widget.onTap),
        child: Text(widget.text),
      ),
    );
  }
}
