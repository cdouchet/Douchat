import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AppLifeCycleListener extends WidgetsBindingObserver {
  final Socket socket;

  AppLifeCycleListener(this.socket);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGING APP LIFE CYCLE");
    print(state.toString());
    super.didChangeAppLifecycleState(state);
  }
}
