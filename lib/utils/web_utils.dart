import 'dart:html';

class WebUtils {
  static void downloadFile(String url, String fileName) {
    AnchorElement anchorElement = AnchorElement(href: url);
    anchorElement.download = fileName;
    anchorElement.click();
  }
}
