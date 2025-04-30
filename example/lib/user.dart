class User {
  String name;
  String email;
  List<User> friends;

  User({
    required this.name,
    required this.email,
    this.friends = const [],
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
        name: json['name'] as String,
        email: json['email'] as String,
        friends: (json['friends'] as List<dynamic>?)
                ?.map((e) =>
                    e is Map<String, dynamic> ? User.fromMap(e) : e as User)
                .toList() ??
            [],
      );
}
