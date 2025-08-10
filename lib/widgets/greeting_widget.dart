import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C853), // dark green
            Color(0xFFB9F6CA), // light green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/farmer.jpg",
                        fit: BoxFit.cover,
                        width: 80, // match 2x radius
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Hello 👋🏾 TestUser",
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Let's Optimize your farming Today with Smart AI",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
