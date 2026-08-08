import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class ServiceCategoryCard extends StatelessWidget {
  const ServiceCategoryCard({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
    this.width = 100,
  });

  final String image;
  final String label;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryColor.withValues(alpha: 0.12),
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.06),
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radius14),
                    topRight: Radius.circular(AppRadius.radius14),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 95,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
