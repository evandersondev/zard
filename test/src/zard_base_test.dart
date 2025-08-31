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

  test('Refine deve falhar com idade < 18', () async {
    final map = {
      'name': 'John Doe',
      'age': 15, // Idade inválida: 15 < 18
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

    // Deve lançar ZardError porque 15 < 18
    expect(() => userSchema.parse(map), throwsA(isA<ZardError>()));
  });

  test('Refine deve passar com idade > 18', () async {
    final map = {
      'name': 'John Doe',
      'age': 20, // Idade válida: 20 > 18
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

    // Deve passar sem erro
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
