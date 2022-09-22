import 'package:douchat3/api/api.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/foundation.dart';

class DouchatNotificationIcon {
  final String id;
  Uint8List? bytes;
  DouchatNotificationIcon({required this.id, required this.bytes});
  void changeBytes(Uint8List b) => bytes = b;
}

class NotificationPhotoRegistar {
  static List<DouchatNotificationIcon> notificationIcons = [];
  static List<DouchatNotificationIcon> groupNotificationIcons = [];

  static populate(List<DouchatNotificationIcon> listOfIcons) =>
      notificationIcons.addAll(listOfIcons);

  static populateGroup(List<DouchatNotificationIcon> listOfIcons) =>
      groupNotificationIcons.addAll(listOfIcons);

  static Uint8List? getBytesFromId(String id) {
    Utils.logger.i('All notification icons : ');
    Utils.logger.i(notificationIcons);
    return notificationIcons.firstWhere((n) => n.id == id).bytes;
  }

  static Uint8List? getBytedFromGroupId(String id) {
    groupNotificationIcons.forEach((element) {
      print(element.id);
    });
    Utils.logger.i('Group id : ' + id);
    Utils.logger.i('All group notification icons : ');
    Utils.logger.i(groupNotificationIcons);
    return groupNotificationIcons.firstWhere((n) => n.id == id).bytes;
  }

  static addIcon(DouchatNotificationIcon icon) => notificationIcons.add(icon);

  static addGroupIcon(DouchatNotificationIcon icon) =>
      groupNotificationIcons.add(icon);

  static updateIconBytes({required String id, required Uint8List bytes}) =>
      notificationIcons.firstWhere((n) => n.id == id).changeBytes(bytes);

  static updateGroupIconBytes({required String id, required Uint8List bytes}) =>
      groupNotificationIcons.firstWhere((n) => n.id == id).changeBytes(bytes);

  static Future<void> setup() async {
    notificationIcons.add(DouchatNotificationIcon(
        id: 'person',
        bytes: (await Api.getContactPhoto(
                url:
                    'https://cdn.icon-icons.com/icons2/1369/PNG/512/-person_90382.png'))
            .bodyBytes));
    groupNotificationIcons.add(DouchatNotificationIcon(
        id: 'group',
        bytes: (await Api.getContactPhoto(
                url:
                    'https://cdn-icons-png.flaticon.com/512/104/104116.png?w=360'))
            .bodyBytes));
  }
}
