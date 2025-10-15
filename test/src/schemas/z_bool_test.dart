import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('ZBool', () {
    test('basic validation - accepts bool', () {
      final schema = z.bool();
      expect(schema.parse(true), isTrue);
      expect(schema.parse(false), isFalse);
    });

    test('rejects non-boolean values', () {
      final schema = z.bool();
      expect(() => schema.parse('true'), throwsA(isA<ZardError>()));
      expect(() => schema.parse(1), throwsA(isA<ZardError>()));
      expect(() => schema.parse(null), throwsA(isA<ZardError>()));
    });

    // Coercion Tests
    group('Coercion', () {
      final schema = z.coerce.bool();

      test('coerces "truthy" values to true', () {
        expect(schema.parse(1), isTrue);
        expect(schema.parse('1'), isTrue);
        expect(schema.parse('true'), isTrue);
        expect(schema.parse('any string'), isTrue);
        expect(schema.parse(true), isTrue);
        expect(schema.parse(123.45), isTrue);
      });

      test('coerces "falsy" values to false', () {
        expect(schema.parse(0), isFalse);
        expect(schema.parse('0'), isFalse);
        expect(schema.parse(''), isFalse);
        expect(schema.parse(false), isFalse);
        expect(schema.parse(null), isFalse);
      });
    });

    // Custom Error Message
    test('custom error message for type', () {
      final schema = z.bool(message: 'Must be a boolean');
      try {
        schema.parse('not a bool');
        fail('Should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.first.message, 'Must be a boolean');
      }
    });

    // ZBool doesn't have other validators like min/max,
    // so chaining after coercion is just about the coercion itself.
    // The tests above cover this.
  });
}
