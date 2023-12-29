// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/apis/api.dart';
import 'package:chatting_app/helper/datetimeutil.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/modals/chat_user.dart';
import 'package:chatting_app/modals/message.dart';
import 'package:chatting_app/screens/chat_screen.dart';
import 'package:chatting_app/widgets/Dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      // elevation: 2.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 4),
      // color: Colors.blue.shade100,
      color: Colors.white,
      // shape: StadiumBorder(),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),
                // leading: CircleAvatar(
                //   child: Icon(CupertinoIcons.person),
                // ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromID != APIs.user.uid
                        ?
                        //show for unread message
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        :
                        //message sent time
                        Text(
                            MyDateUtil.getLastMsgTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
