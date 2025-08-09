import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/widgets/empty_widget.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyPageWidget(
      title: "No Recommendation",
      message: "There are no recommendation yet",
      retryText: "Find Best Crops",
      onRetry: () {
        context.push("/askRecommendation");
      },
    );
  }
}
