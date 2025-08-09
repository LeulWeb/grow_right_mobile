import 'package:flutter/material.dart';
import 'package:grow_right_mobile/route/app_route.dart';
import 'package:grow_right_mobile/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: appRoutes,
    );
  }
}
