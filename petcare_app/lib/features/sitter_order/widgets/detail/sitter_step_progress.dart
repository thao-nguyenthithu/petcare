import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

const double _cham = 18;

// Thanh tiến trình riêng vì có trường hợp mốc ngắt quãng
class SitterStepProgress extends StatelessWidget {
  const SitterStepProgress({
    super.key,
    required this.nhan,
    required this.mocXong,
    this.mocDangO,
  });

  final List<String> nhan;

  final Set<int> mocXong;

  final int? mocDangO;

  bool _noiXanh(int trai) =>
      mocXong.contains(trai) &&
      (mocXong.contains(trai + 1) || trai + 1 == mocDangO);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < nhan.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _Noi(hien: i != 0, xong: _noiXanh(i - 1)),
                    _Cham(xong: mocXong.contains(i), dangO: i == mocDangO),
                    _Noi(hien: i != nhan.length - 1, xong: _noiXanh(i)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nhan[i],
                  textAlign: TextAlign.center,
                  style:
                      (i == mocDangO
                              ? AppTextStyles.labelSm
                              : AppTextStyles.captionSm)
                          .copyWith(
                            color: mocXong.contains(i) || i == mocDangO
                                ? AppColors.primaryColor
                                : AppColors.neutral,
                          ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Noi extends StatelessWidget {
  const _Noi({required this.hien, required this.xong});

  final bool hien;
  final bool xong;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: !hien
            ? Colors.transparent
            : xong
            ? AppColors.primaryColor
            : AppColors.neutralLight,
      ),
    );
  }
}

class _Cham extends StatelessWidget {
  const _Cham({required this.xong, required this.dangO});

  final bool xong;
  final bool dangO;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cham,
      height: _cham,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: xong ? AppColors.primaryColor : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: xong || dangO
              ? AppColors.primaryColor
              : AppColors.neutralLight,
          width: 1.5,
        ),
      ),
      child: xong
          ? const Icon(
              Icons.check_rounded,
              size: 12,
              weight: 900,
              color: AppColors.textWhite,
            )
          : null,
    );
  }
}
