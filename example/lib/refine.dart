// refine(), cross-field validation, and inferType.
import 'package:zard/zard.dart';

void main() {
  // --- refine(): add a custom predicate to any schema ---
  final oddSchema = z.int().refine(
        (n) => n % 2 != 0,
        message: 'Must be an odd number',
      );
  print(oddSchema.parse(7)); // 7
  print(oddSchema.safeParse(4).success); // false

  // --- refine() on strings ---
  final noSpaces = z.string().refine(
        (s) => !s.contains(' '),
        message: 'No spaces allowed',
      );
  print(noSpaces.parse('hello')); // hello
  print(noSpaces.safeParse('hello world').error?.issues.first.message);

  // --- Cross-field validation with ZMap.refine() ---
  final passwordSchema = z
      .map({
        'password': z.string().min(8),
        'confirm': z.string(),
      })
      .refine(
        (data) => data['password'] == data['confirm'],
        message: 'Passwords must match',
      );

  final ok = passwordSchema.safeParse({
    'password': 'secret123',
    'confirm': 'secret123',
  });
  print(ok.success); // true

  final bad = passwordSchema.safeParse({
    'password': 'secret123',
    'confirm': 'different',
  });
  print(bad.success); // false
  print(bad.error?.issues.first.message); // Passwords must match

  // --- inferType: map a ZMap schema to a Dart class ---
  final userSchema = z.map({
    'name': z.string(),
    'age': z.int(),
  });

  final userType = z.inferType<User>(
    fromMap: (m) => User(name: m['name'] as String, age: m['age'] as int),
    mapSchema: userSchema,
  );

  final user = userType.parse({'name': 'Alice', 'age': 30});
  print(user.name); // Alice
  print(user.age); // 30

  // --- List with refine ---
  final nonEmptyList = z.list(z.string()).noempty().min(1);
  print(nonEmptyList.parse(['a', 'b'])); // [a, b]
  print(nonEmptyList.safeParse([]).success); // false
}

class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
}
