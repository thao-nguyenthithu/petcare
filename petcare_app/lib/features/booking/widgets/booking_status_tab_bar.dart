import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_tab_bar.dart';

// Thanh tab trạng thái đơn, năm tab nên để cuộn ngang
class BookingStatusTabBar extends StatelessWidget {
  const BookingStatusTabBar({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) => AppTabBar(labels: labels);
}
