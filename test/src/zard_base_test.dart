import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  test('From map', () async {
    final map = {
      'name': 'John Doe',
      'age': 20,
    };
    final mapError = {
      'name': 'John Doe',
      'age': '20',
    };

    final sucessParsed = User.fromMap(map);

    expect(sucessParsed.name, 'John Doe');
    expect(sucessParsed.age, 20);
    expect(() => User.fromMap(mapError), throwsA(isA<ZardError>()));
  });

  test('Infer type', () async {
    final mapError = {
      'name': 'John Doe',
      'age': 20,
    };
    final result = z
        .inferType<User>(
          fromMap: (map) => User.fromMap(map),
          mapSchema: User.zMap,
        )
        .refine(
          (value) => value.age > 18,
          message: 'Age must be greater than 18',
        )
        .parse(mapError);
  });
}

class User {
  final String name;
  final int age;

  static final zMap = z.map({
    'name': z.string(),
    'age': z.int(),
  });

  User({required this.name, required this.age});

  factory User.fromMap(Map<String, dynamic> map) {
    zMap.parse(map);
    return User(name: map['name'], age: map['age']);
  }
}
