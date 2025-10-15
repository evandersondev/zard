import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('ZInt', () {
    test('basic validation - accepts int', () {
      final schema = z.int();
      expect(schema.parse(42), equals(42));
      expect(schema.parse(0), equals(0));
    });

    test('rejects non-integer values', () {
      final schema = z.int();
      expect(() => schema.parse('42'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(3.14), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    // Coercion Tests
    group('Coercion', () {
      test('coerces string to int', () {
        final schema = z.coerce.int();
        expect(schema.parse('42'), equals(42));
        expect(schema.parse('-10'), equals(-10));
      });

      test('coerces double string to int (truncates)', () {
        final schema = z.coerce.int();
        // int.tryParse will fail for "3.14"
        expect(() => schema.parse('3.14'), throwsA(isA<ZardError>()));
      });

      test('rejects invalid string for coercion', () {
        final schema = z.coerce.int();
        expect(() => schema.parse('abc'), throwsA(isA<ZardError>()));
        expect(() => schema.parse(''), throwsA(isA<ZardError>()));
      });
    });

    // Validator Tests
    test('min validation', () {
      final schema = z.int().min(10);
      expect(schema.parse(15), equals(15));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(9), throwsA(isA<ZardError>()));
    });

    test('max validation', () {
      final schema = z.int().max(10);
      expect(schema.parse(5), equals(5));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
    });

    test('positive validation', () {
      final schema = z.int().positive();
      expect(schema.parse(1), equals(1));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
    });

    test('nonnegative validation', () {
      final schema = z.int().nonnegative();
      expect(schema.parse(0), equals(0));
      expect(schema.parse(1), equals(1));
      expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
    });

    test('negative validation', () {
      final schema = z.int().negative();
      expect(schema.parse(-1), equals(-1));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(1), throwsA(isA<ZardError>()));
    });

    test('multipleOf validation', () {
      final schema = z.int().multipleOf(5);
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
    });

    // Chained Coercion and Validation
    test('coerces and validates min', () {
      final schema = z.coerce.int().min(100);
      expect(schema.parse('150'), equals(150));
      expect(() => schema.parse('50'), throwsA(isA<ZardError>()));
    });

    test('coerces and validates max', () {
      final schema = z.coerce.int().max(50);
      expect(schema.parse('25'), equals(25));
      expect(() => schema.parse('51'), throwsA(isA<ZardError>()));
    });

    // Custom Error Message
    test('custom error message for type', () {
      final schema = z.int(message: 'Must be an integer');
      try {
        schema.parse('invalid');
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.first.message, 'Must be an integer');
      }
    });

    test('custom error message for min validation', () {
      final schema = z.int().min(10, message: 'Too small');
      try {
        schema.parse(5);
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.any((issue) => issue.message == 'Too small'), isTrue);
      }
    });
  });
}
