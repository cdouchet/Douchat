import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Cleaner {
  void cleanApp() async {}

  Future<void> cleanTempDirectory() async {
    final Directory d = await getTemporaryDirectory();
    if (d.existsSync()) {
      await d.delete(recursive: true);
    }
  }
}
