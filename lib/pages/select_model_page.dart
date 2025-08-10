import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/data/scanner_list.dart';
import 'package:grow_right_mobile/widgets/model_selector_widget.dart';

class SelectModelPage extends StatelessWidget {
  const SelectModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Look For Crop Disease")),
      body: Column(
        children: [
          ModelSelectorWidget(
            title: "Coffee",
            description: "Cereal Crop disease detection",
            diseases: 3,
            iconPath: "assets/images/coffee.svg",
            action: () {
              context.push("/inputScan", extra: scannerList[0]);
            },
          ),
          const SizedBox(height: 12),
          ModelSelectorWidget(
            title: "Mango",
            description: "Tropical fruit disease detection",
            diseases: 3,
            iconPath: "assets/images/mango.svg",
            action: () {
              context.push("/inputScan", extra: scannerList[1]);
            },
          ),
          const SizedBox(height: 12),
          ModelSelectorWidget(
            title: "Wheat",
            description: "Cereal Crop disease detection",
            diseases: 2,
            iconPath: "assets/images/wheat.svg",
            action: () {
              context.push("/inputScan", extra: scannerList[2]);
            },
          ),
        ],
      ),
    );
  }
}
