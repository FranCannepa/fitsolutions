import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService instance = NavigationService._internal();

  NavigationService._internal();

  Future<void> pushNamed(String routeName) async {
    await Navigator.pushNamed(navigatorKey.currentContext!, routeName);
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
