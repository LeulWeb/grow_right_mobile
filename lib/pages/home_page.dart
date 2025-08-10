import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:grow_right_mobile/pages/landing_page.dart';
import 'package:grow_right_mobile/pages/profile_page.dart';
import 'package:grow_right_mobile/pages/recommendation_page.dart';
import 'package:hugeicons/hugeicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    const LandingPage(),
    const RecommendationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Grow Right",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CircleNavBar(
        activeIndex: _currentIndex,
        activeIcons: const [
          Icon(HugeIcons.strokeRoundedHome01, color: Colors.white),
          Icon(HugeIcons.strokeRoundedHealtcare, color: Colors.white),
          Icon(HugeIcons.strokeRoundedUser, color: Colors.white),
        ],
        inactiveIcons: const [Text("Home"), Text("Farming"), Text("Profile")],
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
        onTap: (index) => setState(() => _currentIndex = index),
        circleShadowColor: Colors.white,
        elevation: 0,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).canvasColor,
            Theme.of(context).canvasColor,
          ],
        ),
        circleGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
    );
  }
}
