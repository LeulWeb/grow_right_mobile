import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/data/scanner_list.dart';
import 'package:grow_right_mobile/widgets/action_widget.dart';
import 'package:grow_right_mobile/widgets/greeting_widget.dart';
import 'package:grow_right_mobile/widgets/padding_wrapper.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddingWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            GreetingWidget(),
            const SizedBox(height: 12),
            Text(
              "Smart Agriculture Tools",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ActionWidget(
              title: "Scan Crop Disease",
              description: "Take photo to detect plant disease instantly",
              iconPath: "assets/images/plant.svg",
              action: () {
                context.push("/modelList");
              },
            ),
            const SizedBox(height: 12),
            ActionWidget(
              title: "Identify Soil Type",
              description: "Analyze your soil type",
              iconPath: "assets/images/lab.svg",
              action: () {
                context.push("/inputScan", extra: scannerList[3]);
              },
            ),
            const SizedBox(height: 12),
            ActionWidget(
              title: "Get Recommendation",
              description: "Getter personalized advice for better yield",
              iconPath: "assets/images/info.svg",
              action: () {
                context.push("/askRecommendation");
              },
            ),
          ],
        ),
      ),
    );
  }
}
