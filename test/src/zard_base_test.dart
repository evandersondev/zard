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

    final successParsed = User.fromMap(map);

    expect(successParsed.name, 'John Doe');
    expect(successParsed.age, 20);
    expect(() => User.fromMap(mapError), throwsA(isA<ZardError>()));
  });

  test('Refine should fail with age < 18', () async {
    final map = {
      'name': 'John Doe',
      'age': 15, // Invalid age: 15 < 18
    };

    final userSchema = z
        .inferType<User>(
          fromMap: (map) => User.fromMap(map),
          mapSchema: User.zMap,
        )
        .refine(
          (value) => value.age > 18,
          message: 'Age must be greater than 18',
        );

    // Should throw ZardError because 15 < 18
    expect(() => userSchema.parse(map), throwsA(isA<ZardError>()));
  });

  test('Refine should pass with age > 18', () async {
    final map = {
      'name': 'John Doe',
      'age': 20, // Valid age: 20 > 18
    };

    final userSchema = z
        .inferType<User>(
          fromMap: (map) => User.fromMap(map),
          mapSchema: User.zMap,
        )
        .refine(
          (value) => value.age > 18,
          message: 'Age must be greater than 18',
        );

    // Should pass without error
    final user = userSchema.parse(map);
    expect(user.age, 20);
    expect(user.name, 'John Doe');
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
    final validatedMap = zMap.parse(map);
    return User(name: validatedMap['name'], age: validatedMap['age']);
  }
}
