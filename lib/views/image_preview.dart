import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:douchat3/utils/web_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ImagePreview extends StatefulWidget {
  final String imageUrl;
  const ImagePreview({super.key, required this.imageUrl});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    Utils.logger.i('IMAGE URL : ' + widget.imageUrl);
    const FlutterSecureStorage().read(key: 'access_token').then((value) {
      print('COOKIE : $value');
    });
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Stack(children: [
      Align(
          alignment: Alignment.topLeft,
          child: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => Navigator.pop(context))),
      Align(
          alignment: Alignment.topRight,
          child: IconButton(
              icon: Icon(Icons.download, color: Colors.white),
              onPressed: () async {
                final String cookie = (await const FlutterSecureStorage()
                    .read(key: 'access_token'))!;
                if (Platform.isAndroid) {
                  final taskId = await FlutterDownloader.enqueue(
                      url: widget.imageUrl,
                      savedDir: (await getExternalStorageDirectory())!.path,
                      headers: {'cookie': cookie},
                      fileName: widget.imageUrl.split('/').last,
                      openFileFromNotification: true,
                      saveInPublicStorage: true,
                      requiresStorageNotLow: false,
                      showNotification: true);
                } else if (Platform.isIOS) {
                  ImageDownloader.downloadImage(widget.imageUrl,
                      headers: {'cookie': cookie}).then((String? id) {
                    if (id != null) {
                      Fluttertoast.showToast(
                          msg: 'Image téléchargée',
                          gravity: ToastGravity.BOTTOM);
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Erreur durant le téléchargement',
                          gravity: ToastGravity.BOTTOM);
                    }
                  });
                } else if (kIsWeb) {
                  WebUtils.downloadFile(widget.imageUrl);
                }
              })),
      Center(
        child: CachedImageWithCookie(
          image: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.imageUrl,
              // imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
              //   return Image(image: imageProvider);
              // }
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Colors.white)),
        ),
      )
    ]))));
  }
}
