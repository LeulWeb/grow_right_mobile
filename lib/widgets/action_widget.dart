import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final VoidCallback action;
  const ActionWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          subtitle: Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.grey),
          ),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
