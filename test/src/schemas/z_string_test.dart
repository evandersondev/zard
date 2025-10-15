import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('ZString', () {
    test('basic validation - accepts string', () {
      final schema = z.string();
      expect(schema.parse('hello'), equals('hello'));
      expect(schema.parse(''), equals(''));
    });

    test('rejects non-string values', () {
      final schema = z.string();
      expect(() => schema.parse(123), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      expect(() => schema.parse(true), throwsA(isA<ZardError>()));
    });

    // Coercion Tests
    group('Coercion', () {
      test('coerces int to string', () {
        final schema = z.coerce.string();
        expect(schema.parse(123), equals('123'));
      });

      test('coerces double to string', () {
        final schema = z.coerce.string();
        expect(schema.parse(3.14), equals('3.14'));
      });

      test('coerces bool to string', () {
        final schema = z.coerce.string();
        expect(schema.parse(true), equals('true'));
      });

      test('coerces null to empty string', () {
        final schema = z.coerce.string();
        expect(schema.parse(null), equals(''));
      });
    });

    // Validator Tests
    test('min length validation', () {
      final schema = z.string().min(5);
      expect(schema.parse('hello'), equals('hello'));
      expect(() => schema.parse('hi'), throwsA(isA<ZardError>()));
    });

    test('max length validation', () {
      final schema = z.string().max(5);
      expect(schema.parse('hello'), equals('hello'));
      expect(() => schema.parse('hello world'), throwsA(isA<ZardError>()));
    });

    test('exact length validation', () {
      final schema = z.string().length(4);
      expect(schema.parse('four'), equals('four'));
      expect(() => schema.parse('fives'), throwsA(isA<ZardError>()));
    });

    test('email validation', () {
      final schema = z.string().email();
      expect(schema.parse('test@example.com'), equals('test@example.com'));
      expect(() => schema.parse('not-an-email'), throwsA(isA<ZardError>()));
    });

    test('url validation', () {
      final schema = z.string().url();
      expect(
          schema.parse('https://example.com'), equals('https://example.com'));
      expect(() => schema.parse('invalid-url'), throwsA(isA<ZardError>()));
    });

    test('uuid validation', () {
      final schema = z.string().uuid();
      final validUuid = '123e4567-e89b-12d3-a456-426614174000';
      expect(schema.parse(validUuid), equals(validUuid));
      expect(() => schema.parse('not-a-uuid'), throwsA(isA<ZardError>()));
    });

    // Chained Coercion and Validation
    test('coerces and validates min length', () {
      final schema = z.coerce.string().min(5);
      expect(schema.parse(12345), equals('12345'));
      expect(() => schema.parse(123), throwsA(isA<ZardError>()));
    });

    // Custom Error Message
    test('custom error message for type', () {
      final schema = z.string(message: 'Must be a string');
      try {
        schema.parse(123);
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.first.message, 'Must be a string');
      }
    });

    test('custom error message for email validation', () {
      final schema = z.string().email(message: 'Invalid email format');
      try {
        schema.parse('invalid');
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.any((issue) => issue.message == 'Invalid email format'),
            isTrue);
      }
    });
  });
}
