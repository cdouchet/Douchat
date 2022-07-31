import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoProvider extends ChangeNotifier {
  File? _photoFile;
  File? get photoFile => _photoFile;
  final picker = ImagePicker();

  Future<void> getImage() async {
    XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file == null) {
      return;
    }
    _photoFile = File(file.path);
    notifyListeners();
  }
}
