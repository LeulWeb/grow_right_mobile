import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModelSelectorWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final int diseases;
  final VoidCallback action;
  const ModelSelectorWidget({
    super.key,
    required this.title,
    required this.description,
    required this.diseases,
    required this.iconPath,
    required this.action
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 24),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(description),
                Chip(
                  label: Text("Common diseases $diseases"),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
