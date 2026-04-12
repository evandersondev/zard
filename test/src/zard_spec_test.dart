import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('PRIMITIVES', () {
    test('string valid', () {
      expect(z.string().parse('hello'), 'hello');
    });

    test('string invalid', () {
      expect(() => z.string().parse(123), throwsA(isA<ZardError>()));
    });

    test('int min/max', () {
      expect(z.int().min(1).parse(5), 5);
      expect(() => z.int().min(10).parse(5), throwsA(isA<ZardError>()));
    });

    test('double valid', () {
      expect(z.double().parse(1.5), 1.5);
    });

    test('bool valid', () {
      expect(z.bool().parse(true), true);
    });
  });

  // ---------------------------------------------------

  group('OPTIONAL / NULLABLE / DEFAULT', () {
    test('optional allows null', () {
      final schema = z.string().optional();
      expect(schema.parse(null), null);
    });

    test('nullable allows null', () {
      final schema = z.string().nullable();
      expect(schema.parse(null), null);
    });

    test('default applies on null', () {
      final schema = z.string().$default('x');
      expect(schema.parse(null), 'x');
    });

    test('optional + default', () {
      final schema = z.string().optional().$default('x');

      expect(schema.parse(null), 'x');
      expect(schema.parse('hello'), 'hello');
    });

    test('nullable + default', () {
      final schema = z.string().nullable().$default('x');

      expect(schema.parse(null), 'x');
      expect(schema.parse('hello'), 'hello');
    });

    test('nullish', () {
      final schema = z.string().nullish();

      expect(schema.parse(null), null);
    });
  });

  // ---------------------------------------------------

  group('ZMAP BASIC', () {
    final schema = z.map({
      'name': z.string(),
      'age': z.int(),
    });

    test('valid object', () {
      final result = schema.parse({'name': 'John', 'age': 30});
      expect(result['name'], 'John');
      expect(result['age'], 30);
    });

    test('missing required field', () {
      expect(
        () => schema.parse({'name': 'John'}),
        throwsA(isA<ZardError>()),
      );
    });
  });

  // ---------------------------------------------------

  group('ZMAP OPTIONAL / DEFAULT', () {
    final schema = z.map({
      'name': z.string(),
      'age': z.int().optional(),
      'count': z.int().$default(10),
    });

    test('optional missing', () {
      final result = schema.parse({'name': 'John'});
      expect(result.containsKey('age'), false);
    });

    test('default applied when missing', () {
      final result = schema.parse({'name': 'John'});
      expect(result['count'], 10);
    });

    test('default applied when null', () {
      final result = schema.parse({
        'name': 'John',
        'count': null,
      });
      expect(result['count'], 10);
    });
  });

  // ---------------------------------------------------

  group('ZMAP NESTED', () {
    final schema = z.map({
      'user': z.map({
        'name': z.string(),
        'age': z.int(),
      }),
    });

    test('nested valid', () {
      final result = schema.parse({
        'user': {'name': 'John', 'age': 30}
      });

      expect(result['user']['name'], 'John');
    });

    test('nested invalid path', () {
      try {
        schema.parse({
          'user': {'name': 'John', 'age': 'invalid'}
        });
      } catch (e) {
        final err = e as ZardError;
        expect(err.issues.first.path, contains('user.age'));
      }
    });
  });

  // ---------------------------------------------------

  group('STRICT MODE', () {
    final schema = z.map({
      'name': z.string(),
    }).strict();

    test('rejects extra fields', () {
      expect(
        () => schema.parse({'name': 'John', 'extra': 1}),
        throwsA(isA<ZardError>()),
      );
    });
  });

  // ---------------------------------------------------

  group('ZLIST', () {
    final schema = z.list(z.string());

    test('valid list', () {
      final result = schema.parse(['a', 'b']);
      expect(result.length, 2);
    });

    test('invalid item', () {
      expect(
        () => schema.parse(['a', 1]),
        throwsA(isA<ZardError>()),
      );
    });
  });

  // ---------------------------------------------------

  group('TRANSFORM', () {
    test('transform works', () {
      final schema = z.string().transform((v) => v.toUpperCase());
      expect(schema.parse('abc'), 'ABC');
    });

    test('multiple transforms', () {
      final schema = z
          .string()
          .transform((v) => v + '!')
          .transform((v) => v.toUpperCase());

      expect(schema.parse('abc'), 'ABC!');
    });
  });

  // ---------------------------------------------------

  group('REFINE', () {
    test('refine valid', () {
      final schema = z.int().refine((v) => v > 10);

      expect(schema.parse(20), 20);
    });

    test('refine invalid', () {
      final schema = z.int().refine((v) => v > 10);

      expect(() => schema.parse(5), throwsA(isA<ZardError>()));
    });

    test('refine on map', () {
      final schema = z.map({
        'password': z.string(),
        'confirm': z.string(),
      }).refine((data) => data['password'] == data['confirm']);

      expect(
        () => schema.parse({'password': '123', 'confirm': '456'}),
        throwsA(isA<ZardError>()),
      );
    });
  });

  // ---------------------------------------------------

  group('ASYNC', () {
    test('parseAsync works', () async {
      final schema = z.string();
      final result = await schema.parseAsync(Future.value('hello'));
      expect(result, 'hello');
    });
  });

  // ---------------------------------------------------

  group('SAFE PARSE', () {
    test('success true', () {
      final result = z.string().safeParse('ok');
      expect(result.success, true);
      expect(result.data, 'ok');
    });

    test('success false', () {
      final result = z.string().safeParse(123);
      expect(result.success, false);
      expect(result.error, isNotNull);
    });
  });

  // ---------------------------------------------------

  group('ENUM', () {
    final schema = z.$enum(['a', 'b']);

    test('valid enum', () {
      expect(schema.parse('a'), 'a');
    });

    test('invalid enum', () {
      expect(() => schema.parse('c'), throwsA(isA<ZardError>()));
    });
  });

  // ---------------------------------------------------

  group('COERCE', () {
    test('string to int', () {
      expect(z.coerce.int().parse('10'), 10);
    });

    test('string to double', () {
      expect(z.coerce.double().parse('10.5'), 10.5);
    });

    test('string to bool', () {
      expect(z.coerce.bool().parse(''), false);
    });
  });

  // ---------------------------------------------------

  group('DATE', () {
    test('valid date string', () {
      final result = z.date().safeParse('2021-01-01');
      expect(result.success, true);
    });

    test('invalid date', () {
      expect(() => z.date().parse('invalid'), throwsA(isA<ZardError>()));
    });
  });

  // ---------------------------------------------------

  group('EDGE CASES', () {
    test('deep nesting', () {
      final schema = z.map({
        'a': z.map({
          'b': z.map({
            'c': z.string(),
          }),
        }),
      });

      final result = schema.parse({
        'a': {
          'b': {'c': 'ok'}
        }
      });

      expect(result['a']['b']['c'], 'ok');
    });

    test('empty object', () {
      final schema = z.map({});
      expect(schema.parse({}), {});
    });

    test('empty list', () {
      final schema = z.list(z.string());
      expect(schema.parse([]), []);
    });
  });
}
