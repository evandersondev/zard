// Async parsing: parseAsync(), safeParseAsync(), lazy schemas.
import 'package:zard/zard.dart';

void main() async {
  // --- parseAsync() with a direct value ---
  final schema = z.string().min(3);
  final value = await schema.parseAsync('hello');
  print(value); // hello

  // --- parseAsync() with a Future value ---
  final asyncValue = await schema.parseAsync(Future.value('world'));
  print(asyncValue); // world

  // --- safeParseAsync() returns a ZardResult future ---
  final result = await schema.safeParseAsync(Future.value('hi'));
  print(result.success); // false (too short)
  print(result.error?.issues.first.message);

  // --- Async object schema ---
  final userSchema = z.map({
    'name': z.string().min(1),
    'age': z.int().min(0),
  });

  final user = await userSchema.parseAsync(
    Future.value({'name': 'Alice', 'age': 30}),
  );
  print(user); // {name: Alice, age: 30}

  // --- lazy(): circular/self-referencing schemas ---
  late Schema<Map<String, dynamic>> nodeSchema;
  nodeSchema = z.map({
    'value': z.string(),
    'children': z.list(z.lazy(() => nodeSchema)).optional(),
  });

  final tree = nodeSchema.parse({
    'value': 'root',
    'children': [
      {'value': 'child1'},
      {
        'value': 'child2',
        'children': [
          {'value': 'grandchild'},
        ],
      },
    ],
  });
  print(tree['value']); // root
  print((tree['children'] as List).length); // 2

  // lazy async
  final lazyStr = z.lazy<String>(() => z.string().min(2));
  print(await lazyStr.parseAsync(Future.value('ok'))); // ok
}
