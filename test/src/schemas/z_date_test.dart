import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('ZDate', () {
    final now = DateTime.now();
    final dateString = '2023-10-27T10:00:00.000Z';
    final parsedDate = DateTime.parse(dateString);

    test('basic validation - accepts DateTime object', () {
      final schema = z.date();
      expect(schema.parse(now), equals(now));
    });

    test('basic validation - accepts valid date string', () {
      final schema = z.date();
      // The base ZDate parse can handle ISO 8601 strings
      expect(schema.parse(dateString), equals(parsedDate));
    });

    test('rejects non-date values', () {
      final schema = z.date();
      expect(() => schema.parse(12345), throwsA(isA<ZardError>()));
      expect(() => schema.parse('not a date'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    // Coercion Tests
    group('Coercion', () {
      final schema = z.coerce.date();

      test('coerces valid date string to DateTime', () {
        expect(schema.parse(dateString), equals(parsedDate));
      });

      test('accepts DateTime object directly', () {
        expect(schema.parse(now), equals(now));
      });

      test('rejects invalid string for coercion', () {
        expect(() => schema.parse('invalid-date'), throwsA(isA<ZardError>()));
        expect(() => schema.parse(''), throwsA(isA<ZardError>()));
      });

      test('coerces null to throw error', () {
        expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      });
    });

    // ZDate doesn't have extra validators like min/max yet,
    // but if they were added, tests would go here.
    // For example: z.coerce.date().min(someDate)

    // Custom Error Message
    test('custom error message for type', () {
      final schema = z.date(message: 'Must be a valid date');
      try {
        schema.parse('invalid');
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.first.message, 'Must be a valid date');
      }
    });
  });
}
