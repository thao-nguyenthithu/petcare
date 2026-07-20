import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Danh sách ngang các nhóm dịch vụ.
class ServiceCategories extends StatelessWidget {
  const ServiceCategories({super.key, required this.categories});

  final List<MockServiceCategory> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 166,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _ServiceCard(image: category.image, label: category.name);
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.image, required this.label});

  final String image;
  final String label;

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
        onTap: () => baoDangPhatTrien(context),
        splashColor: AppColors.primaryColor.withValues(alpha: 0.12),
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.06),
        child: SizedBox(
          width: 100,
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
                    height: 105,
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
