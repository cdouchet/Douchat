class User {
  final String id;
  String username;
  String photoUrl;

  User({required this.id, required this.username, required this.photoUrl});

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'photoUrl': photoUrl};

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'], username: json['username'], photoUrl: json['photoUrl']);
}
