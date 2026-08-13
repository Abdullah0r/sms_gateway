class UserModel {
  final int id;
  final String username;
  final String? name;
  final String token;

  UserModel({
    required this.id,
    required this.username,
    this.name,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      username: (json['username'] ?? json['email'] ?? json['name'] ?? '').toString(),
      name: json['name']?.toString(),
      token: token,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'name': name,
    'token': token,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      username: map['username'] ?? '',
      name: map['name'],
      token: map['token'] ?? '',
    );
  }
}
