// Transforms: transform(), transformTyped(), and the coerce API.
import 'package:zard/zard.dart';

void main() {
  // --- transform(): map a validated value to a new value of the same type ---
  final uppercaseSchema = z.string().min(1).transform((s) => s.toUpperCase());
  print(uppercaseSchema.parse('hello')); // HELLO

  // --- transformTyped(): map to a different type ---
  final lengthSchema = z.string().transformTyped<int>((s) => s.length);
  print(lengthSchema.parse('hello')); // 5

  // --- coerce.string(): coerces non-string values to strings ---
  final strCoerce = z.coerce.string();
  print(strCoerce.parse(42)); // '42'
  print(strCoerce.parse(true)); // 'true'

  // --- coerce.int(): coerces string digits to int ---
  final intCoerce = z.map({
    'num': z.coerce.int(),
  });
  print(intCoerce.parse({'num': '7'})); // 7
  print(intCoerce.parse({'num': 42})); // 42

  // --- coerce.double() ---
  final dblCoerce = z.coerce.double();
  print(dblCoerce.parse('3.14')); // 3.14
  print(dblCoerce.parse(2)); // 2.0

  // --- coerce.bool() ---
  final boolCoerce = z.coerce.bool();
  print(boolCoerce.parse(1)); // true
  print(boolCoerce.parse(0)); // false
  print(boolCoerce.parse('')); // false
  print(boolCoerce.parse('yes')); // true

  // --- coerce.date() ---
  final dateCoerce = z.coerce.date();
  print(dateCoerce.parse('2024-01-15').year); // 2024

  // --- Chaining transforms ---
  final pipeline = z.string().trim().toLowerCase().transform((s) => 'user:$s');
  print(pipeline.parse('  ALICE  ')); // user:alice
}
