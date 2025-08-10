import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: double.infinity, // ensures bounded width if inside Column
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
              child: SvgPicture.asset(iconPath, width: 24),
            ),
            const SizedBox(width: 20),

            // Make the text area take remaining width
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  // No inner Row needed
                  Text(
                    description,
                    softWrap: true,
                    // optional:
                    // maxLines: 3,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          "Common diseases $diseases",
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: Theme.of(context).primaryColor),
                        ),
                        shape: const StadiumBorder(),
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withAlpha(50),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
