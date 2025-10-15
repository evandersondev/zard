import 'package:test/test.dart';
import 'package:zard/zard.dart' hide ZCoerceDouble;

void main() {
  group('ZDouble', () {
    test('basic validation - accepts double', () {
      final schema = z.double();
      expect(schema.parse(3.14), equals(3.14));
      expect(schema.parse(0.0), equals(0.0));
    });

    test('converts int to double', () {
      final schema = z.coerce.double();
      final result = schema.parse(42);
      expect(result, equals(42.0));
      expect(result.runtimeType.toString(), equals('double'));
    });

    test('rejects non-numeric values', () {
      final schema = z.double(); // ZDouble should reject non-doubles
      expect(() => schema.parse('3.14'),
          throwsA(isA<ZardError>())); // Fails, it's a string
      expect(() => schema.parse('42'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    test('min validation', () {
      final schema = z.double().min(10.0);
      expect(schema.parse(15.0), equals(15.0));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(9.9), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.0), throwsA(isA<ZardError>()));
    });

    test('min validation with int input converted to double', () {
      final schema = z.coerce.double().min(10);
      expect(schema.parse(15), equals(15.0));
      expect(schema.parse(10), equals(10.0));
      expect(() => schema.parse(9), throwsA(isA<ZardError>()));
    });

    test('max validation', () {
      final schema = z.double().max(10.0);
      expect(schema.parse(5.0), equals(5.0));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(10.1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(15.0), throwsA(isA<ZardError>()));
    });

    test('max validation with int input converted to double', () {
      final schema = z.coerce.double().max(10);
      expect(schema.parse(5), equals(5.0));
      expect(schema.parse(10), equals(10.0));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
    });

    test('min and max range validation', () {
      final schema = z.double().min(0.0).max(10.0);
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(10.1), throwsA(isA<ZardError>()));
    });

    test('positive validation', () {
      final schema = z.double().positive();
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(0.1), equals(0.1));
      expect(() => schema.parse(0.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-5.5), throwsA(isA<ZardError>()));
    });

    test('positive validation with int input coerced to double', () {
      final schema = z.coerce.double().positive();
      expect(schema.parse(5), equals(5.0));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-5), throwsA(isA<ZardError>()));
    });

    test('nonnegative validation', () {
      final schema = z.double().nonnegative();
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(5.5), equals(5.5));
      expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
    });

    test('negative validation', () {
      final schema = z.double().negative();
      expect(schema.parse(-5.5), equals(-5.5));
      expect(schema.parse(-0.1), equals(-0.1));
      expect(() => schema.parse(0.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.5), throwsA(isA<ZardError>()));
    });

    test('multipleOf validation', () {
      final schema = z.double().multipleOf(0.5);
      expect(schema.parse(0.5), equals(0.5));
      expect(schema.parse(1.0), equals(1.0));
      expect(schema.parse(1.5), equals(1.5));
      expect(() => schema.parse(1.3), throwsA(isA<ZardError>()));
    });

    test('step validation (alias for multipleOf)', () {
      final schema = z.double().step(2.0);
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(2.0), equals(2.0));
      expect(schema.parse(4.0), equals(4.0));
      expect(() => schema.parse(3.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.0), throwsA(isA<ZardError>()));
    });

    test('custom error messages', () {
      final schema = z.double(message: 'Custom error message');
      try {
        schema.parse('invalid');
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<ZardError>());
        final error = e as ZardError;
        expect(error.issues.first.message, equals('Custom error message'));
      }
    });

    test('custom error message for min validation', () {
      final schema = z.double().min(10.0, message: 'Must be at least 10.0');
      try {
        schema.parse(5.0);
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<ZardError>());
        final error = e as ZardError;
        expect(
            error.issues
                .any((issue) => issue.message == 'Must be at least 10.0'),
            isTrue);
      }
    });

    test('coerce always returns double even with int input', () {
      final schema = z.coerce.double();
      final result = schema.parse(42);
      expect(result, equals(42.0));
      expect(result.runtimeType, equals(double));
    });
  });
}
