import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('Nullish Tests', () {
    test('nullish should mark schema as both nullable and optional', () {
      final schema = z.string().nullish();
      expect(schema.isNullable, isTrue);
      expect(schema.isOptional, isTrue);
    });

    test('nullish should work in ZMap with null value', () {
      final schema = z.map({
        'name': z.string(),
        'nickname': z.string().nullish(),
      });

      final result = schema.parse({'name': 'John', 'nickname': null});
      expect(result['name'], equals('John'));
      expect(result['nickname'], isNull);
    });

    test('nullish should work in ZMap with omitted field', () {
      final schema = z.map({
        'name': z.string(),
        'nickname': z.string().nullish(),
      });

      final result = schema.parse({'name': 'John'});
      expect(result['name'], equals('John'));
      expect(result.containsKey('nickname'), isFalse);
    });

    test('nullish should work in ZMap with actual value', () {
      final schema = z.map({
        'name': z.string(),
        'nickname': z.string().nullish(),
      });

      final result = schema.parse({'name': 'John', 'nickname': 'Johnny'});
      expect(result['name'], equals('John'));
      expect(result['nickname'], equals('Johnny'));
    });

    test('nullish should be equivalent to nullable().optional()', () {
      final nullishSchema = z.string().nullish();
      final combinedSchema = z.string().nullable().optional();

      expect(nullishSchema.isNullable, equals(combinedSchema.isNullable));
      expect(nullishSchema.isOptional, equals(combinedSchema.isOptional));
    });

    test('nullish with ZInt', () {
      final schema = z.map({
        'required': z.int(),
        'optional': z.int().nullish(),
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
      final schema = z.map({
        'user': z.map({
          'name': z.string(),
          'email': z.string().email().nullish(),
          'age': z.int().nullish(),
        }),
        'metadata': z.map({
          'createdAt': z.string(),
          'updatedAt': z.string().nullish(),
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
