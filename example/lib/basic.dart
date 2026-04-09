// Basic Zard usage: string, number, bool, date validation and safeParse.
import 'package:zard/zard.dart';

void main() {
  // --- String ---
  final nameSchema = z.string().min(2).max(50);
  print(nameSchema.parse('Alice')); // Alice

  final emailSchema = z.string().email();
  final emailResult = emailSchema.safeParse('not-an-email');
  print(emailResult.success); // false
  print(emailResult.error?.issues.first.message); // Invalid email

  // --- Int ---
  final ageSchema = z.int().min(0).max(120);
  print(ageSchema.parse(30)); // 30

  final badAge = ageSchema.safeParse(-1);
  print(badAge.success); // false

  // --- Double ---
  final priceSchema = z.double().positive();
  print(priceSchema.parse(9.99)); // 9.99

  // --- Bool ---
  final flagSchema = z.bool();
  print(flagSchema.parse(true)); // true

  // --- Date ---
  final dateSchema = z.date();
  final date = dateSchema.parse('2024-06-15');
  print(date.runtimeType); // DateTime
  print(date.year); // 2024

  // --- Enum ---
  final roleSchema = z.$enum(['admin', 'user', 'guest']);
  print(roleSchema.parse('admin')); // admin

  final badRole = roleSchema.safeParse('superuser');
  print(badRole.success); // false

  // --- safeParse returns a ZardResult with success/data/error ---
  final result = z.string().min(3).safeParse('hi');
  if (!result.success) {
    for (final issue in result.error!.issues) {
      print('${issue.type}: ${issue.message}');
    }
  }
}
