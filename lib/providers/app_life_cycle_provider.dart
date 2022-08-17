import 'package:flutter/widgets.dart';

class AppLifeCycleProvider extends ChangeNotifier {
  late AppLifecycleState _state;
  AppLifecycleState get state => _state;

  void setAppState(AppLifecycleState newState) {
    _state = newState;
  }
}
