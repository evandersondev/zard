import 'package:zard/zard.dart';

void mapsHelper() {
  final ignoreSchema = z.map({
    'name': z.string().min(3).max(20),
    'age': z.int().min(18).max(80).nullable(),
    'email': z.string().email(),
    'isActive': z.bool().optional(),
    'createdAt': z.date().nullable().optional(),
  });

  final ignore = ignoreSchema.parse({
    'name': 'John Doe',
    'age': null,
    'email': 'john.doe@example.com',
    // 'isActive': true,
    // 'createdAt': null,
  });
  print(ignore);
}
