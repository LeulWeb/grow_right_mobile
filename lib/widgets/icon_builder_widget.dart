import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconBuilderWidget extends StatelessWidget {
  final String icon;
  const IconBuilderWidget({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SvgPicture.string(icon, color: isDark ? Colors.white : Colors.black);
  }
}
