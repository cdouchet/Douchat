import 'dart:html';
import 'dart:io';

import 'package:douchat3/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/models/response_data.dart';
import 'package:http_interceptor/models/request_data.dart';

class GlobalInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    if (!kIsWeb) {
      data.headers['cookie'] =
          (await const FlutterSecureStorage().read(key: 'access_token'))!;
    } else {
      Utils.logger.i("SETTING HEADER FOR WEB");
      try {
        data.headers.addAll({
          HttpHeaders.authorizationHeader: "Bearer ${document.cookie!.split('=')[1]}"
        });
        // data.headers['authorization'] = "Bearer ${document.cookie!.split('=')[1]}";
      } catch (e, s) {
        Utils.logger.e("Error settings AUTHORIZATION Header", e, s);
      }
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data;
  }
}
