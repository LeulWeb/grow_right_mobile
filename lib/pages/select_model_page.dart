import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/data/scanner_list.dart';
import 'package:grow_right_mobile/widgets/model_selector_widget.dart';
import 'package:grow_right_mobile/widgets/padding_wrapper.dart';

class SelectModelPage extends StatelessWidget {
  const SelectModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Look For Crop Disease")),
      body: PaddingWrapper(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(40),
                child: SvgPicture.asset(
                  "assets/images/plant.svg",
                  width: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Choose the type of crop you want to analyze for disease detection",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
