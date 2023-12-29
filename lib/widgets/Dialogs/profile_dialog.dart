import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/modals/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .4,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .2),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
            Positioned(
              left: mq.width * .04,
              top: mq.height * .015,
              width: mq.width * .55,
              child: Text(
                user.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  onPressed: () {
                    // for moving to profile screen
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 30,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
