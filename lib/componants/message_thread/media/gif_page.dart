import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/api/tenor.dart';
import 'package:douchat3/componants/shared/cached_image_with_cookie.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GifPage extends StatefulWidget {
  const GifPage({Key? key}) : super(key: key);

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> with AutomaticKeepAliveClientMixin {
  final TenorApi tenorApi = TenorApi();
  Timer timer = Timer(Duration(seconds: 1), () {});
  late Future<Response> tenorCall = tenorApi.getFeatured(limit: '30');
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      timer = Timer(Duration(seconds: 1), () {
        if (!timer.isActive) {
          print('Call api');
          if (controller.text.isNotEmpty) {
            tenorCall = tenorApi.search(search: controller.text, limit: '30');
          } else {
            tenorCall = tenorApi.getFeatured(limit: '30');
          }
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            // bottom:
            //     MediaQuery.of(context).viewInsets.bottom
          ),
          child: TextFormField(
              autocorrect: false,
              controller: controller,
              cursorColor: primary,
              maxLines: 1,
              minLines: 1,
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 16),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(6),
                  prefixIcon: Icon(Icons.search, size: 18, color: primary),
                  prefixIconColor: primary,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                      gapPadding: 6),
                  fillColor: bubbleDark,
                  filled: true)),
        ),
        Expanded(
          child: FutureBuilder<Response>(
              future: tenorCall,
              builder:
                  (BuildContext context, AsyncSnapshot<Response> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    final Map<String, dynamic> res =
                        jsonDecode(snapshot.data!.body);
                    if (res['results'] != null) {
                      if ((res['results'] as List).isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 16, left: 16, top: 16),
                          child: GridView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: res['results'].length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12),
                              itemBuilder: (BuildContext context, int index) {
                                final String url = res['results'][index]
                                    ['media_formats']['tinygif']['url'];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(
                                        context, {'type': 'gif', 'url': url});
                                  },
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedImageWithCookie(
                                        image: CachedNetworkImage(
                                            imageUrl: url,
                                            fit: BoxFit.fill,
                                            progressIndicatorBuilder:
                                                (BuildContext context,
                                                        String url,
                                                        DownloadProgress
                                                            loadingProgress) =>
                                                    LoadingAnimationWidget
                                                        .threeArchedCircle(
                                                            color: Colors.white,
                                                            size: 50)),
                                      )),
                                );
                              }),
                        );
                      } else {
                        print('No result from search');
                        return Center(
                            child:
                                Container(child: Text('Pas de résultats :(')));
                      }
                    } else {
                      print('Error: results is null');
                      return Center(child: Container(child: Icon(Icons.error)));
                    }
                    // return GridView.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder)
                  } else {
                    print('Tenor gifs data is null');
                    return const Center(child: Icon(Icons.error));
                  }
                } else if (snapshot.hasError) {
                  print('Tenor api call has error');
                  return const Center(child: Icon(Icons.error));
                } else {
                  print('Tenor has no data');
                  return Container();
                }
              }),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
