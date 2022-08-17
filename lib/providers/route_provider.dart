import 'package:flutter/widgets.dart';

class RouteProvider extends ChangeNotifier {
  String _route = '';
  String get route => _route;

  void changeRoute(String newRoute) {
    _route = newRoute;
    notifyListeners();
  }
}
