import 'package:flutter/material.dart';
import 'package:grow_right_mobile/widgets/greeting_widget.dart';
import 'package:grow_right_mobile/widgets/padding_wrapper.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddingWrapper(
      child: SingleChildScrollView(
        child: Column(children: [const SizedBox(height: 12), GreetingWidget()]),
      ),
    );
  }
}
