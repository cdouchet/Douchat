import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';

class CachedImageWithCookie extends StatefulWidget {
  final CachedNetworkImage image;
  const CachedImageWithCookie({super.key, required this.image});

  @override
  State<CachedImageWithCookie> createState() => _CachedImageWithCookieState();
}

class _CachedImageWithCookieState extends State<CachedImageWithCookie> {
  late Future<String> future;
  Future<String> getCookie() async {
    return kIsWeb
        ? document.cookie!.split('=')[1]
        : (await const FlutterSecureStorage().read(key: 'access_token')) ?? "";
  }

  @override
  void initState() {
    super.initState();
    future = getCookie();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.hasData) {
            final i = widget.image;
            return CachedNetworkImage(
              imageUrl: i.imageUrl,
              alignment: i.alignment,
              cacheKey: i.cacheKey,
              cacheManager: i.cacheManager,
              color: i.color,
              colorBlendMode: i.colorBlendMode,
              errorWidget: i.errorWidget,
              fadeInCurve: i.fadeInCurve,
              fadeInDuration: i.fadeInDuration,
              fadeOutCurve: i.fadeOutCurve,
              fadeOutDuration: i.fadeOutDuration,
              filterQuality: i.filterQuality,
              fit: i.fit,
              height: i.height,
              httpHeaders: kIsWeb ? {"authorization": "Bearer ${snap.data}"} : {'cookie': snap.data},
              imageBuilder: i.imageBuilder,
              key: i.key,
              matchTextDirection: i.matchTextDirection,
              maxHeightDiskCache: i.maxHeightDiskCache,
              maxWidthDiskCache: i.maxWidthDiskCache,
              memCacheHeight: i.memCacheHeight,
              memCacheWidth: i.memCacheWidth,
              placeholder: i.placeholder,
              placeholderFadeInDuration: i.placeholderFadeInDuration,
              progressIndicatorBuilder: i.progressIndicatorBuilder,
              repeat: i.repeat,
              useOldImageOnUrlChange: i.useOldImageOnUrlChange,
              width: i.width,
              imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
            );
          } else {
            return LoadingAnimationWidget.threeArchedCircle(
                color: Colors.white, size: 30);
          }
        });
  }
}
