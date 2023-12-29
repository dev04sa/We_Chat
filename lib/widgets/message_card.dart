import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/apis/api.dart';
import 'package:chatting_app/helper/datetimeutil.dart';
import 'package:chatting_app/helper/dialogs.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/modals/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromID;
    return InkWell(
      onLongPress: () {
        _bottomSheetShow(isMe);
      },
      child: isMe ? _greenMsg() : _blueMsg(),
    );
  }

  Widget _blueMsg() {
    if (widget.message.read.isEmpty) {
      APIs.updateReadMessageStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 179, 227, 250),
                border: Border.all(color: Colors.blue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            padding: EdgeInsets.all(mq.width * .04),
            child: widget.message.type == Type.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  )
                : Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_outlined,
                size: 18,
                color: Colors.blue,
              ),
            SizedBox(
              width: mq.width * .01,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 194, 226, 158),
                border: Border.all(color: Colors.green),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            padding: EdgeInsets.all(mq.width * .04),
            child: widget.message.type == Type.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      // height: mq.height * .5,
                      // width: mq.width * .1,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  )
                : Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                  ),
          ),
        ),
      ],
    );
  }

  void _bottomSheetShow(bool isME) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: const BoxDecoration(color: Colors.grey),
              ),
              widget.message.type == Type.text
                  ? _OptationItem(
                      const Icon(
                        Icons.copy_all_outlined,
                        size: 25,
                        color: Colors.blue,
                      ),
                      'Copy Text', () async {
                      await Clipboard.setData(
                          ClipboardData(text: widget.message.msg));
                      Navigator.pop(context);
                      Dialogs.showSnackbar(context, 'Text Copied !');
                    })
                  : _OptationItem(
                      const Icon(
                        Icons.download,
                        size: 25,
                        color: Colors.blue,
                      ),
                      'Save Image', () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'We chat')
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, 'Image Saved Sucessfully');
                          }
                        });
                      } catch (e) {
                        log(e.toString());
                      }
                    }),
              if (isME)
                Divider(
                  color: Colors.black,
                  indent: mq.width * .04,
                  endIndent: mq.width * .04,
                ),
              if (widget.message.type == Type.text && isME)
                _OptationItem(
                    const Icon(
                      Icons.edit,
                      size: 25,
                      color: Colors.blue,
                    ),
                    'Edit Message', () {
                  Navigator.pop(context);
                  _showUpdateMessageDialog();
                }),
              if (isME)
                _OptationItem(
                    const Icon(
                      Icons.delete_forever,
                      size: 25,
                      color: Colors.red,
                    ),
                    'Delete Message', () async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, 'Message Deleted !');
                  });
                }),
              Divider(
                color: Colors.black,
                indent: mq.width * .04,
                endIndent: mq.width * .04,
              ),
              _OptationItem(
                  const Icon(
                    Icons.remove_red_eye,
                    size: 25,
                    color: Colors.blue,
                  ),
                  'Send At : ${MyDateUtil.getMsgTime(context: context, time: widget.message.sent)}',
                  () {}),
              _OptationItem(
                  const Icon(
                    Icons.remove_red_eye,
                    size: 25,
                    color: Colors.green,
                  ),
                  widget.message.read.isEmpty
                      ? 'Read At : Not Seen yet'
                      : 'Read At : ${MyDateUtil.getMsgTime(context: context, time: widget.message.read)}',
                  () {}),
            ],
          );
        });
  }

  void _showUpdateMessageDialog() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, bottom: 10, top: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 28,
                    color: Colors.blue,
                  ),
                  Text(' Update Message')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => updateMsg = value,
                initialValue: updateMsg,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updateMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}

class _OptationItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptationItem(this.icon, this.name, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .07,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '  $name',
              style: const TextStyle(fontSize: 20, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
