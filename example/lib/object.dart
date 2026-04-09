// Object (map) schema: nested schemas, optional/nullable, strict, partial,
// merge, extend, pick, omit, keyof.
import 'package:zard/zard.dart';

void main() {
  // --- Basic object schema ---
  final addressSchema = z.map({
    'street': z.string(),
    'city': z.string(),
    'zip': z.string().min(4).max(10),
  });

  final userSchema = z.map({
    'name': z.string().min(1),
    'age': z.int().min(0),
    'email': z.string().email().optional(),
    'address': addressSchema.nullable(),
  });

  final user = userSchema.parse({
    'name': 'Bob',
    'age': 25,
    'address': null,
  });
  print(user); // {name: Bob, age: 25, address: null}

  // --- strict() rejects unknown keys ---
  final strictSchema = z.map({'x': z.int()}).strict();
  final strictResult = strictSchema.safeParse({'x': 1, 'y': 2});
  print(strictResult.success); // false

  // --- partial(): all fields become optional ---
  final partialUser = userSchema.partial();
  print(partialUser.parse({'name': 'Alice'})); // {name: Alice}

  // --- partial(keys: [...]): specific fields become optional ---
  final partialEmail = userSchema.partial(keys: ['email', 'address']);
  print(partialEmail.parse({'name': 'Carol', 'age': 30}));

  // --- merge(): combine two schemas (second wins on key conflicts) ---
  final extraSchema = z.map({'role': z.string()});
  final merged = userSchema.merge(extraSchema);
  final mergedUser = merged.parse({
    'name': 'Dave',
    'age': 40,
    'address': null,
    'role': 'admin',
  });
  print(mergedUser['role']); // admin

  // --- extend(): add fields ---
  final extended = z.map({'id': z.int()}).extend({'label': z.string()});
  print(extended.parse({'id': 1, 'label': 'hello'}));

  // --- pick() / omit() ---
  final nameOnly = userSchema.pick(['name']);
  print(nameOnly.parse({'name': 'Eve'}));

  final withoutAge = userSchema.omit(['age']).partial();
  print(withoutAge.parse({'name': 'Frank', 'address': null}));

  // --- keyof(): returns an enum schema of the schema's keys ---
  final keys = userSchema.keyof();
  print(keys.parse('name')); // name
  print(keys.safeParse('unknown').success); // false
}
