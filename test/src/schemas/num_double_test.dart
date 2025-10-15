import 'package:test/test.dart';
import 'package:zard/src/schemas/z_double_copy.dart';
import 'package:zard/zard.dart' hide ZCoerceDouble;

void main() {
  group('ZNum', () {
    test('basic validation - accepts both int and double', () {
      final schema = z.num();
      expect(schema.parse(42), equals(42));
      expect(schema.parse(42) is int, isTrue);
      expect(schema.parse(3.14), equals(3.14));
      expect(schema.parse(3.14) is double, isTrue);
    });

    test('rejects non-numeric values', () {
      final schema = z.num();
      expect(() => schema.parse('3.14'), throwsA(isA<ZardError>()));
      expect(() => schema.parse('42'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    test('min validation with int', () {
      final schema = z.num().min(10);
      expect(schema.parse(15), equals(15));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(9), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5), throwsA(isA<ZardError>()));
    });

    test('min validation with double', () {
      final schema = z.num().min(10.5);
      expect(schema.parse(15.5), equals(15.5));
      expect(schema.parse(10.5), equals(10.5));
      expect(() => schema.parse(10.4), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.5), throwsA(isA<ZardError>()));
    });

    test('max validation with int', () {
      final schema = z.num().max(10);
      expect(schema.parse(5), equals(5));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
      expect(() => schema.parse(15), throwsA(isA<ZardError>()));
    });

    test('max validation with double', () {
      final schema = z.num().max(10.5);
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(10.5), equals(10.5));
      expect(() => schema.parse(10.6), throwsA(isA<ZardError>()));
      expect(() => schema.parse(15.5), throwsA(isA<ZardError>()));
    });

    test('min and max range validation', () {
      final schema = z.num().min(0).max(10);
      expect(schema.parse(0), equals(0));
      expect(schema.parse(5), equals(5));
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
    });

    test('positive validation', () {
      final schema = z.num().positive();
      expect(schema.parse(5), equals(5));
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(0.1), equals(0.1));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-5), throwsA(isA<ZardError>()));
    });

    test('nonnegative validation', () {
      final schema = z.num().nonnegative();
      expect(schema.parse(0), equals(0));
      expect(schema.parse(5), equals(5));
      expect(schema.parse(5.5), equals(5.5));
      expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
    });

    test('negative validation', () {
      final schema = z.num().negative();
      expect(schema.parse(-5), equals(-5));
      expect(schema.parse(-5.5), equals(-5.5));
      expect(schema.parse(-0.1), equals(-0.1));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5), throwsA(isA<ZardError>()));
    });

    test('multipleOf validation with integers', () {
      final schema = z.num().multipleOf(3);
      expect(schema.parse(0), equals(0));
      expect(schema.parse(3), equals(3));
      expect(schema.parse(6), equals(6));
      expect(schema.parse(9), equals(9));
      expect(() => schema.parse(1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5), throwsA(isA<ZardError>()));
    });

    test('multipleOf validation with decimals', () {
      final schema = z.num().multipleOf(0.5);
      expect(schema.parse(0.5), equals(0.5));
      expect(schema.parse(1.0), equals(1.0));
      expect(schema.parse(1.5), equals(1.5));
      expect(() => schema.parse(1.3), throwsA(isA<ZardError>()));
    });

    test('step validation (alias for multipleOf)', () {
      final schema = z.num().step(5);
      expect(schema.parse(0), equals(0));
      expect(schema.parse(5), equals(5));
      expect(schema.parse(10), equals(10));
      expect(() => schema.parse(3), throwsA(isA<ZardError>()));
      expect(() => schema.parse(7), throwsA(isA<ZardError>()));
    });

    test('custom error messages', () {
      final schema = ZNum(message: 'Custom error message');
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
      final schema = z.num().min(10, message: 'Must be at least 10');
      try {
        schema.parse(5);
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<ZardError>());
        final error = e as ZardError;
        expect(error.issues.any((issue) => issue.message == 'Must be at least 10'), isTrue);
      }
    });

    test('preserves int type when given int', () {
      final schema = z.num();
      final result = schema.parse(42);
      expect(result, equals(42));
      expect(result.runtimeType.toString(), equals('int'));
    });

    test('preserves double type when given double', () {
      final schema = z.num();
      final result = schema.parse(42.5);
      expect(result, equals(42.5));
      expect(result.runtimeType, equals(double));
    });
  });

  group('ZDoubleCopy', () {
    test('basic validation - accepts double', () {
      final schema = z.doubleCopy();
      expect(schema.parse(3.14), equals(3.14));
      expect(schema.parse(0.0), equals(0.0));
    });

    test('converts int to double', () {
      final schema = z.doubleCopy();
      final result = schema.parse(42);
      expect(result, equals(42.0));
      expect(result.runtimeType.toString(), equals('double'));
    });

    test('rejects non-numeric values', () {
      final schema = z.doubleCopy();
      expect(() => schema.parse('3.14'), throwsA(isA<ZardError>()));
      expect(() => schema.parse('42'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    test('min validation', () {
      final schema = z.doubleCopy().min(10.0);
      expect(schema.parse(15.0), equals(15.0));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(9.9), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.0), throwsA(isA<ZardError>()));
    });

    test('min validation with int input converted to double', () {
      final schema = z.doubleCopy().min(10);
      expect(schema.parse(15), equals(15.0));
      expect(schema.parse(10), equals(10.0));
      expect(() => schema.parse(9), throwsA(isA<ZardError>()));
    });

    test('max validation', () {
      final schema = z.doubleCopy().max(10.0);
      expect(schema.parse(5.0), equals(5.0));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(10.1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(15.0), throwsA(isA<ZardError>()));
    });

    test('max validation with int input converted to double', () {
      final schema = z.doubleCopy().max(10);
      expect(schema.parse(5), equals(5.0));
      expect(schema.parse(10), equals(10.0));
      expect(() => schema.parse(11), throwsA(isA<ZardError>()));
    });

    test('min and max range validation', () {
      final schema = z.doubleCopy().min(0.0).max(10.0);
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(10.0), equals(10.0));
      expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(10.1), throwsA(isA<ZardError>()));
    });

    test('positive validation', () {
      final schema = z.doubleCopy().positive();
      expect(schema.parse(5.5), equals(5.5));
      expect(schema.parse(0.1), equals(0.1));
      expect(() => schema.parse(0.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-5.5), throwsA(isA<ZardError>()));
    });

    test('positive validation with int input', () {
      final schema = z.doubleCopy().positive();
      expect(schema.parse(5), equals(5.0));
      expect(() => schema.parse(0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(-5), throwsA(isA<ZardError>()));
    });

    test('nonnegative validation', () {
      final schema = z.doubleCopy().nonnegative();
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(5.5), equals(5.5));
      expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
    });

    test('negative validation', () {
      final schema = z.doubleCopy().negative();
      expect(schema.parse(-5.5), equals(-5.5));
      expect(schema.parse(-0.1), equals(-0.1));
      expect(() => schema.parse(0.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.5), throwsA(isA<ZardError>()));
    });

    test('multipleOf validation', () {
      final schema = z.doubleCopy().multipleOf(0.5);
      expect(schema.parse(0.5), equals(0.5));
      expect(schema.parse(1.0), equals(1.0));
      expect(schema.parse(1.5), equals(1.5));
      expect(() => schema.parse(1.3), throwsA(isA<ZardError>()));
    });

    test('step validation (alias for multipleOf)', () {
      final schema = z.doubleCopy().step(2.0);
      expect(schema.parse(0.0), equals(0.0));
      expect(schema.parse(2.0), equals(2.0));
      expect(schema.parse(4.0), equals(4.0));
      expect(() => schema.parse(3.0), throwsA(isA<ZardError>()));
      expect(() => schema.parse(5.0), throwsA(isA<ZardError>()));
    });

    test('custom error messages', () {
      final schema = ZDoubleCopy(message: 'Custom error message');
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
      final schema = z.doubleCopy().min(10.0, message: 'Must be at least 10.0');
      try {
        schema.parse(5.0);
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<ZardError>());
        final error = e as ZardError;
        expect(error.issues.any((issue) => issue.message == 'Must be at least 10.0'), isTrue);
      }
    });

    test('always returns double even with int input', () {
      final schema = z.doubleCopy();
      final result = schema.parse(42);
      expect(result, equals(42.0));
      expect(result.runtimeType, equals(double));
    });
  });

  group('ZCoerceDouble', () {
    test('coerces string to double', () {
      final schema = z.coerceDouble();
      expect(schema.parse('3.14'), equals(3.14));
      expect(schema.parse('42'), equals(42.0));
      expect(schema.parse('0'), equals(0.0));
    });

    test('accepts double directly', () {
      final schema = z.coerceDouble();
      expect(schema.parse(3.14), equals(3.14));
      expect(schema.parse(42.0), equals(42.0));
    });

    test('coerces int to double', () {
      final schema = z.coerceDouble();
      expect(schema.parse(42), equals(42.0));
      expect(schema.parse(0), equals(0.0));
    });

    test('rejects invalid strings', () {
      final schema = z.coerceDouble();
      expect(() => schema.parse('not a number'), throwsA(isA<ZardError>()));
      expect(() => schema.parse('abc'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(''), throwsA(isA<ZardError>()));
    });

    test('handles edge cases', () {
      final schema = z.coerceDouble();
      expect(schema.parse('3.14159'), equals(3.14159));
      expect(schema.parse('-42.5'), equals(-42.5));
      expect(schema.parse('0.0'), equals(0.0));
    });
  });

  group('ZNum vs ZDoubleCopy comparison', () {
    test('ZNum preserves original type', () {
      final numSchema = z.num();

      final intResult = numSchema.parse(42);
      expect(intResult, equals(42));
      expect(intResult.runtimeType.toString(), equals('int'));

      final doubleResult = numSchema.parse(42.0);
      expect(doubleResult, equals(42.0));
      expect(doubleResult.runtimeType.toString(), equals('double'));
    });

    test('ZDoubleCopy always converts to double', () {
      final doubleSchema = z.doubleCopy();

      final intResult = doubleSchema.parse(42);
      expect(intResult, equals(42.0));
      expect(intResult.runtimeType.toString(), equals('double'));

      final doubleResult = doubleSchema.parse(42.0);
      expect(doubleResult, equals(42.0));
      expect(doubleResult.runtimeType.toString(), equals('double'));
    });

    test('both handle validations correctly', () {
      final numSchema = z.num().min(10).max(20);
      final doubleSchema = z.doubleCopy().min(10).max(20);

      // Both accept valid values
      expect(numSchema.parse(15), equals(15));
      expect(doubleSchema.parse(15), equals(15.0));

      // Both reject values outside range
      expect(() => numSchema.parse(5), throwsA(isA<ZardError>()));
      expect(() => doubleSchema.parse(5), throwsA(isA<ZardError>()));
      expect(() => numSchema.parse(25), throwsA(isA<ZardError>()));
      expect(() => doubleSchema.parse(25), throwsA(isA<ZardError>()));
    });
  });
}
