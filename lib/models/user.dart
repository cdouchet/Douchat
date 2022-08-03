class User {
  final String id;
  String username;
  String photoUrl;
  bool online;

  User(
      {required this.id,
      required this.username,
      required this.photoUrl,
      required this.online});

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'photoUrl': photoUrl, 'online': online};

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      username: json['username'],
      photoUrl: json['photoUrl'],
      online: json['online']);

  setOnline(bool newOnline) => online = newOnline;
  setUsername(String newUsername) => username = newUsername;
  setPhotoUrl(String url) => photoUrl = url;
}
