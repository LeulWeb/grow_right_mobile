import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AskRecommendationPage extends StatelessWidget {
  const AskRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            context.pop();
          },
        ),

        title: Text("Find Best Crop"),
      ),
    );
  }
}
