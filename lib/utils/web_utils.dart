import 'dart:html';

class WebUtils {
  static void downloadFile(String url) {
    AnchorElement anchorElement = AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }
}
