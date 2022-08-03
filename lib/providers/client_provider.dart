import 'package:douchat3/models/user.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClientProvider extends ChangeNotifier {
  String? _photoUrl;
  String? get photoUrl => _photoUrl;
  late User _client;
  User get client => _client;
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void changePhotoUrl(String newPhotoUrl) {
    _photoUrl = newPhotoUrl;
    notifyListeners();
  }

  void setAccessToken(String token) {
    secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<void> setClient(User user) async {
    print('setting client');
    _client = user;
  }
}
