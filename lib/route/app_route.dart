import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/pages/ask_recommendation_page.dart';
import 'package:grow_right_mobile/pages/home_page.dart';
import 'package:grow_right_mobile/pages/input_screen_page.dart';
import 'package:grow_right_mobile/pages/scan_result_page.dart';

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
      path: '/scanResult',
      name: 'scanResult',
      builder: (context, state) {
        return ScanResultPage();
      },
    ),
    GoRoute(
      path: '/inputScan',
      name: 'inputScan',
      builder: (context, state) {
        // final scanner = state.extra;
        return InputScreenPage();
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
