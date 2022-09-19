import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
                final taskId = await FlutterDownloader.enqueue(
                    url: widget.imageUrl,
                    savedDir: (await getExternalStorageDirectory())!.path,
                    headers: {
                      'cookie': (await const FlutterSecureStorage()
                          .read(key: 'access_token'))!
                    },
                    fileName: widget.imageUrl.split('/').last,
                    openFileFromNotification: true,
                    saveInPublicStorage: true,
                    requiresStorageNotLow: false,
                    showNotification: true);
              })),
      Center(
        child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            errorWidget: (context, url, error) =>
                Icon(Icons.error, color: Colors.white)),
      )
    ]))));
  }
}
