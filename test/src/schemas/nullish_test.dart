import 'package:test/test.dart';
import 'package:zard/src/schemas/schemas.dart';

void main() {
  group('Nullish Tests', () {
    test('nullish should mark schema as both nullable and optional', () {
      final schema = ZString().nullish();
      expect(schema.isNullable, isTrue);
      expect(schema.isOptional, isTrue);
    });

    test('nullish should work in ZMap with null value', () {
      final schema = ZMap({
        'name': ZString(),
        'nickname': ZString().nullish(),
      });

      final result = schema.parse({'name': 'John', 'nickname': null});
      expect(result['name'], equals('John'));
      expect(result['nickname'], isNull);
    });

    test('nullish should work in ZMap with omitted field', () {
      final schema = ZMap({
        'name': ZString(),
        'nickname': ZString().nullish(),
      });

      final result = schema.parse({'name': 'John'});
      expect(result['name'], equals('John'));
      expect(result.containsKey('nickname'), isFalse);
    });

    test('nullish should work in ZMap with actual value', () {
      final schema = ZMap({
        'name': ZString(),
        'nickname': ZString().nullish(),
      });

      final result = schema.parse({'name': 'John', 'nickname': 'Johnny'});
      expect(result['name'], equals('John'));
      expect(result['nickname'], equals('Johnny'));
    });

    test('nullish should be equivalent to nullable().optional()', () {
      final nullishSchema = ZString().nullish();
      final combinedSchema = ZString().nullable().optional();

      expect(nullishSchema.isNullable, equals(combinedSchema.isNullable));
      expect(nullishSchema.isOptional, equals(combinedSchema.isOptional));
    });

    test('nullish with ZInt', () {
      final schema = ZMap({
        'required': ZInt(),
        'optional': ZInt().nullish(),
      });

      // Com null
      final result1 = schema.parse({'required': 42, 'optional': null});
      expect(result1['optional'], isNull);

      // Sem o campo
      final result2 = schema.parse({'required': 42});
      expect(result2.containsKey('optional'), isFalse);

      // Com valor
      final result3 = schema.parse({'required': 42, 'optional': 10});
      expect(result3['optional'], equals(10));
    });

    test('complex nested nullish fields', () {
      final schema = ZMap({
        'user': ZMap({
          'name': ZString(),
          'email': ZString().email().nullish(),
          'age': ZInt().nullish(),
        }),
        'metadata': ZMap({
          'createdAt': ZString(),
          'updatedAt': ZString().nullish(),
        }).nullish(),
      });

      // Metadata completamente null
      final result = schema.parse({
        'user': {
          'name': 'John',
        },
        'metadata': null,
      });

      expect(result['user']['name'], equals('John'));
      expect(result['metadata'], isNull);
    });
  });
}
