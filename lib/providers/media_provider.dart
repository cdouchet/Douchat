import 'dart:io';

import 'package:flutter/widgets.dart';

class MediaProvider extends ChangeNotifier {
  late List<File> _files = [];
  late List<File> _pickedFiles = [];
  List<File> get files => _files;
  List<File> get pickedFiles => _pickedFiles;

  void addFile(File file) {
    _files.add(file);
    notifyListeners();
  }

  void removeFile(File file) {
    _files.removeWhere((f) => f.path == file.path);
    notifyListeners();
  }

  void removeAtIndex(int index) {
    _files.removeAt(index);
    notifyListeners();
  }

  void removePickedFilesAtIndex(int index) {
    _pickedFiles.removeAt(index);
    notifyListeners();
  }

  void addAllFiles(List<File> newFiles) {
    _files.addAll(newFiles);
    notifyListeners();
  }

  void addAllPickedFiles(List<File> f) {
    _pickedFiles.addAll(f);
    notifyListeners();
  }

  void setFiles(List<File> nFiles) {
    _files = nFiles;
    notifyListeners();
  }

  void setPickedFiles(List<File> f) {
    _pickedFiles = f;
    notifyListeners();
  }

  void removeAllFiles() {
    _files.clear();
    notifyListeners();
  }
}
