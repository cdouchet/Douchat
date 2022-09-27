import 'package:douchat3/utils/utils.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    Utils.logger.i('Native called background task : $task');
    return Future.value(true);
  });
}
