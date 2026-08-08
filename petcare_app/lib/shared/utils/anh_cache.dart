import 'package:flutter/widgets.dart';

int beRongCache(BuildContext context, double beRongO) =>
    (beRongO * MediaQuery.devicePixelRatioOf(context)).round();
