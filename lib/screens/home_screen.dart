import 'dart:convert';
import 'dart:developer';

import 'package:chatting_app/apis/api.dart';
import 'package:chatting_app/helper/dialogs.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/modals/chat_user.dart';
import 'package:chatting_app/screens/profile_screen.dart';
import 'package:chatting_app/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSeraching = false;
//

  _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    APIs.getSelfInfo().then((value) {
      setState(() {});
    });
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSeraching) {
            setState(() {
              _isSeraching = !_isSeraching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              Icons.home_outlined,
              size: 30.0,
            ),
            title: _isSeraching
                ? TextField(
                    style: const TextStyle(fontSize: 17.0, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Name , About ...',
                      border: InputBorder.none,
                    ),
                  )
                : const Text(
                    'We Chat',
                  ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSeraching = !_isSeraching;
                    });
                  },
                  icon: Icon(
                    _isSeraching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,
                    size: 25.0,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    size: 25.0,
                  )),
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getMyUserId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSeraching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSeraching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.amber,
            onPressed: () {
              _addChatUserDialog();
            },
            child: const Icon(Icons.message),
          ),
        ),
      ),
      // body: StreamBuilder(
      //   stream: APIs.getAllUsers(),
      //   builder: (context, snapshot) {
      //     switch (snapshot.connectionState) {
      //       case ConnectionState.waiting:
      //       case ConnectionState.none:
      //         return const Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       case ConnectionState.active:
      //       case ConnectionState.done:
      //         final data = snapshot.data?.docs;
      //         _list =
      //             data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
      //                 [];
      //         if (_list.isNotEmpty) {
      //           return ListView.builder(
      //             padding: EdgeInsets.only(top: mq.height * .01),
      //             physics: const BouncingScrollPhysics(),
      //             itemCount:
      //                 _isSeraching ? _searchList.length : _list.length,
      //             // itemBuilder: (context, index) => ChatUserCard(),
      //             itemBuilder: (context, index) {
      //               return ChatUserCard(
      //                   user: _isSeraching
      //                       ? _searchList[index]
      //                       : _list[index]);
      //               // return Text('Name: ${list[index]}');
      //             },
      //           );
      //         } else {
      //           return Center(
      //             child: const Text(
      //               'No Connections Found !',
      //               style: TextStyle(fontSize: 22.0),
      //             ),
      //           );
      //         }
      //     }

      //     // final data = snapshot.data?.docs;
      //     // for (var i in data!) {
      //     //   log('Data: ${jsonEncode(i.data())}');
      //     //   list.add(i.data()['name']);
      //     //   // list.add(i.data()['about']);
      //     // }
      //   },
      // ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 10, top: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    size: 28,
                    color: Colors.blue,
                  ),
                  Text(' Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Enter Email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      log(email);
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User Doesn\'t exist ');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}
