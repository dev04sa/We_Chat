import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:chatting_app/modals/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../modals/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAHLDrjVQ:APA91bGkFoQWNpUFnSToiqn3UTHg-CA77l_WPjbrugBxgdJo6mnqbVIBj52ftFkn8sN13QGACxtE7ZtMho2avB1S6aV7YBk3wHWoL73gh_XswBju6VqFlMGLzpLfKyrOKSxglFSKtDd4'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> getSelfInfo() async {
    try {
      final userSnapshot =
          await firestore.collection('users').doc(user.uid).get();
      if (userSnapshot.exists) {
        me = ChatUser.fromJson(userSnapshot.data()!);
        await getFirebaseMessagingToken();
        updateActiveStatus(true);

        log(userSnapshot.data().toString());
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    } catch (e) {
      // Handle the case where 'me' is not initialized
      me = ChatUser(
          id: '',
          name: '',
          email: '',
          about: '',
          image: '',
          createdAt: '',
          isOnline: false,
          lastActive: '',
          pushToken: '');
    }
  }

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    try {
      final data = await firestore
          .collection('users')
          .where('email ',
              isEqualTo:
                  email) // after the email one Whitespace is required otherwise it is null
          .get();

      log('data: ${data.docs}');

      if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
        // user exists
        log('user exists: ${data.docs.first.data()}');

        firestore
            .collection('users')
            .doc(user.uid)
            .collection('my_users')
            .doc(data.docs.first.id)
            .set({});
        return true;
      } else {
        // user doesn't exist
        return false;
      }
    } catch (e) {
      log('Error occurred: $e');
      return false;
    }
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: 'Hey !  I am  using We Chat',
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: "");
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatuser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, msg, type));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    // ignore: unnecessary_null_comparison
    if (me == null) {
      // Handle the case where 'me' is null
      return;
    }
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log("Extension : $ext ");

    final ref = storage.ref().child('Profile_Pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log("File Transfered : ${p0.bytesTransferred / 1000} ")});

    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //  Message Implementation

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/message/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        toID: chatuser.id,
        read: '',
        type: type,
        fromID: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatuser.id)}/message/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatuser, type == Type.text ? msg : "image"));
  }

  static Future<void> updateReadMessageStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromID)}/message/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toID)}/message/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updatemsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toID)}/message/')
        .doc(message.sent)
        .update({'msg': updatemsg});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/message/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    log("Extension : $ext ");

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log("File Transfered : ${p0.bytesTransferred / 1000} ")});

    final ImageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, ImageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }
}
