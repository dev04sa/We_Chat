class ChatUser {
  ChatUser({
    required this.image,
    required this.email,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.id,
    required this.lastActive,
    required this.isOnline,
    required this.pushToken,
  });
  late String image;
  late String email;
  late String about;
  late String name;
  late String createdAt;
  late String id;
  late String lastActive;
  late bool isOnline;
  late String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    email = json['email '] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    isOnline = json['is_online'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['email '] = email;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    return data;
  }
}
