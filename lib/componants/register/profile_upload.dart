import 'package:douchat3/providers/profile_photo.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileUpload extends StatelessWidget {
  const ProfileUpload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider =
        Provider.of<ProfilePhotoProvider>(context, listen: true);
    return SizedBox(
        height: 126.0,
        width: 126.0,
        child: Material(
          color: isLightTheme(context)
              ? const Color(0x0ff2f2f2)
              : const Color(0xFF211E1E),
          borderRadius: BorderRadius.circular(126.0),
          child: InkWell(
              onTap: () async => userProvider.getImage(),
              borderRadius: BorderRadius.circular(126.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: userProvider.photoFile == null
                          ? const Icon(Icons.person_outline_rounded,
                              size: 126.0, color: Colors.black)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(126),
                              child: Image.file(userProvider.photoFile!,
                                  width: 126,
                                  height: 126,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, object, stackTrace) =>
                                      const Icon(Icons.person_outline_rounded,
                                          size: 126.0, color: Colors.black)))),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.add_circle_rounded,
                        size: 38.0, color: primary),
                  )
                ],
              )),
        ));
  }
}
