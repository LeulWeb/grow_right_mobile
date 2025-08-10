import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/models/finding_result_model.dart';
import 'package:grow_right_mobile/models/tflite_model.dart';
import 'package:grow_right_mobile/pages/ask_recommendation_page.dart';
import 'package:grow_right_mobile/pages/home_page.dart';
import 'package:grow_right_mobile/pages/input_screen_page.dart';
import 'package:grow_right_mobile/pages/scan_result_page.dart';
import 'package:grow_right_mobile/pages/select_model_page.dart';

final appRoutes = GoRouter(
  initialLocation: "/home",
  // redirect: (context, state) {

  // },
  routes: [
    GoRoute(
      path: "/home",
      name: "home",
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: "/modelList",
      name: "modelList",
      builder: (context, state) => SelectModelPage(),
    ),

    GoRoute(
      path: '/scanResult',
      builder: (context, state) {
        final result = state.extra as FindingResultModel;
        return ScanResultPage(result: result,);
      },
    ),
    GoRoute(
      path: '/inputScan',
      name: 'inputScan',
      builder: (context, state) {
        final scanner = state.extra as TfliteModel;
        return InputScreen(scanner: scanner);
      },
    ),
    GoRoute(
      path: '/askRecommendation',
      name: 'askRecommendation',
      builder: (context, state) {
        // final scanner = state.extra;
        return AskRecommendationPage();
      },
    ),
  ],
);
