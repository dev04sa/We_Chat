import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/helper/datetimeutil.dart';
import 'package:chatting_app/modals/chat_user.dart';
import 'package:chatting_app/modals/message.dart';
import 'package:chatting_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../apis/api.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  bool emoji = false, _isuploading = false;
  final _textcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (emoji) {
              setState(() {
                emoji = !emoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 153, 215, 245),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            // child: CircularProgressIndicator(),
                            child: Text('Dev'),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log(jsonEncode(data![0].data()));
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) => MessageCard(
                                message: _list[index],
                              ),
                              // itemBuilder: (context, index) {
                              //   return Text('Name: Dev');
                              // },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No Connections Found !',
                                style: TextStyle(fontSize: 22.0),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isuploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: CircularProgressIndicator(),
                      )),
                _chatInput(),
                if (emoji)
                  SizedBox(
                    height: mq.height * .37,
                    child: EmojiPicker(
                      textEditingController: _textcontroller,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 153, 215, 245),
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: InkWell(
          onTap: () {},
          child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .045,
                      height: mq.height * .045,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  )
                ],
              );
            },
          )),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .015, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          emoji = !emoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  Expanded(
                    child: TextField(
                      controller: _textcontroller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (emoji) {
                          setState(() {
                            emoji = !emoji;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type Something ...',
                          hintStyle:
                              TextStyle(color: Colors.blueAccent, fontSize: 20),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        setState(() {
                          _isuploading = true;
                        });

                        for (var i in images) {
                          APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isuploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.image_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          // log(image.path);
                          setState(() {
                            _isuploading = true;
                          });

                          APIs.sendChatImage(widget.user, File(image.path));
                          setState(() {
                            _isuploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            onPressed: () {
              if (_textcontroller.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _textcontroller.text, Type.text);
                } else {
                  APIs.sendMessage(
                      widget.user, _textcontroller.text, Type.text);
                }
                _textcontroller.text = '';
              }
            },
            shape: const CircleBorder(),
            minWidth: 0,
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
