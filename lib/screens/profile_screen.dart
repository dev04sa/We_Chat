import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/apis/api.dart';
import 'package:chatting_app/helper/dialogs.dart';
import 'package:chatting_app/modals/chat_user.dart';
import 'package:chatting_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? _image;
  final _formKey = GlobalKey<FormState>();
  _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile Screen',
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressbar(context);
              await APIs.auth.signOut().then(
                (value) async {
                  APIs.updateActiveStatus(false);
                  await GoogleSignIn().signOut().then((value) {
                    // for hiding progress bar
                    Navigator.pop(context);
                    // for hiding home screen
                    Navigator.pop(context);
                    APIs.auth = FirebaseAuth.instance;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                },
              );

              // _signOut();
              log('log out');
            },
            backgroundColor: Colors.red,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.12,
                    ),
                    Stack(
                      children: [
                        (_image != null)
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                // child: CachedNetworkImage(
                                //   imageUrl:
                                //       'https://example.com/image.jpg', // Replace this with a valid image URL
                                //   placeholder: (context, url) =>
                                //       CircularProgressIndicator(),
                                //   errorWidget: (context, url, error) =>
                                //       Icon(Icons.error),
                                // ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.user.image,
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1.0,
                            onPressed: () => _bottomSheetShow(),
                            // onPressed: () async {
                            //   final ImagePicker picker = ImagePicker();
                            //   // Pick an image.
                            //   final XFile? image = await picker.pickImage(
                            //       source: ImageSource.gallery);

                            //   setState(() {
                            //     _image = image!.path;
                            //   });
                            // },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: mq.height * 0.05,
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 22.0),
                    ),
                    SizedBox(
                      height: mq.height * 0.05,
                    ),
                    TextFormField(
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      initialValue: widget.user.name,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          hintText: ' eg. Happy Singh',
                          label: Text(
                            'Name',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          hintText: ' eg. Feeling Happy ',
                          label: Text(
                            'About',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * 0.5, mq.height * 0.06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, "Profile Updated Sucessfully");
                          });
                          log('Inside Validator');
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'UPDATE',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _bottomSheetShow() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            shrinkWrap: true,
            children: [
              Text(
                "Pick Profile Picture",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      setState(() {
                        _image = image!.path;
                      });
                      APIs.updateProfilePicture(File(_image!));

                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/images/gallery.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      setState(() {
                        _image = image!.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/images/camera.png'),
                  ),
                ],
              )
            ],
          );
        });
  }
}
