import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('Schemas Integration Tests', () {
    group('ZNum', () {
      test('basic validation', () {
        final schema = z.num();
        expect(schema.parse(42), equals(42)); // int permanece int
        expect(schema.parse(42) is int, isTrue);
        expect(schema.parse(3.14), equals(3.14)); // double permanece double
        expect(schema.parse(3.14) is double, isTrue);
        expect(() => schema.parse('3.14'), throwsA(isA<ZardError>()));
      });

      test('min and max', () {
        final schema = z.num().min(0).max(10);

        expect(schema.parse(5), equals(5));
        expect(schema.parse(5.5), equals(5.5));
        expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
        expect(() => schema.parse(11), throwsA(isA<ZardError>()));
      });

      test('positive, nonnegative, negative', () {
        expect(z.num().positive().parse(5), equals(5));
        expect(z.num().positive().parse(5.5), equals(5.5));
        expect(() => z.num().positive().parse(0), throwsA(isA<ZardError>()));

        expect(z.num().nonnegative().parse(0), equals(0));
        expect(
            () => z.num().nonnegative().parse(-1), throwsA(isA<ZardError>()));

        expect(z.num().negative().parse(-5), equals(-5));
        expect(z.num().negative().parse(-5.5), equals(-5.5));
        expect(() => z.num().negative().parse(0), throwsA(isA<ZardError>()));
      });

      test('multipleOf and step', () {
        final schema = z.num().multipleOf(3);
        expect(schema.parse(6), equals(6));
        expect(() => schema.parse(5), throwsA(isA<ZardError>()));

        final stepSchema = z.num().step(5);
        expect(stepSchema.parse(10), equals(10));
        expect(() => stepSchema.parse(7), throwsA(isA<ZardError>()));
      });

      test('ZNum accepts both int and double in map', () {
        final schema = z.map({
          'price': z.num(),
        });

        // Deve aceitar int e manter como int
        final result1 = schema.parse({'price': 42});
        expect(result1['price'], equals(42));
        expect(result1['price'] is int, isTrue);

        // Deve aceitar double e manter como double
        final result2 = schema.parse({'price': 42.0});
        expect(result2['price'], equals(42.0));
        expect(result2['price'] is double, isTrue);
      });
    });

    group('ZList', () {
      test('basic validation', () {
        final schema = z.list(z.string());
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse('not a list'), throwsA(isA<ZardError>()));
      });

      test('validates items', () {
        final schema = z.list(z.int());
        expect(schema.parse([1, 2, 3]), equals([1, 2, 3]));
        expect(() => schema.parse([1, 'two', 3]), throwsA(isA<ZardError>()));
      });

      test('min and max length', () {
        final schema = z.list(z.string()).min(2).max(5);
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse(['a']), throwsA(isA<ZardError>()));
        expect(() => schema.parse(['a', 'b', 'c', 'd', 'e', 'f']),
            throwsA(isA<ZardError>()));
      });

      test('noempty validation', () {
        final schema = z.list(z.string()).noempty();
        expect(schema.parse(['a']), equals(['a']));
        expect(() => schema.parse([]), throwsA(isA<ZardError>()));
      });

      test('exact length', () {
        final schema = z.list(z.string()).lenght(3);
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse(['a', 'b']), throwsA(isA<ZardError>()));
      });

      test('nested lists', () {
        final schema = z.list(z.list(z.int()));
        expect(
            schema.parse([
              [1, 2],
              [3, 4]
            ]),
            equals([
              [1, 2],
              [3, 4]
            ]));
      });
    });

    group('ZMap', () {
      test('basic validation', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
        });

        final result = schema.parse({'name': 'John', 'age': 30});
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('validates required fields', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
        });

        expect(() => schema.parse({'name': 'John'}), throwsA(isA<ZardError>()));
      });

      test('optional fields', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int().optional(),
        });

        final result = schema.parse({'name': 'John'});
        expect(result['name'], equals('John'));
        expect(result.containsKey('age'), isFalse);
      });

      test('nullable fields', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int().nullable(),
        });

        final result = schema.parse({'name': 'John', 'age': null});
        expect(result['name'], equals('John'));
        expect(result['age'], isNull);
      });

      test('strict mode', () {
        final schema = z.map({
          'name': z.string(),
        }).strict();

        expect(() => schema.parse({'name': 'John', 'extra': 'field'}),
            throwsA(isA<ZardError>()));
      });

      test('nested maps', () {
        final schema = z.map({
          'user': z.map({
            'name': z.string(),
            'email': z.string().email(),
          }),
        });

        final result = schema.parse({
          'user': {'name': 'John', 'email': 'john@example.com'}
        });
        expect(result['user']['name'], equals('John'));
      });

      test('pick method', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
          'email': z.string(),
        });

        final pickedSchema = schema.pick(['name', 'email']);
        final result =
            pickedSchema.parse({'name': 'John', 'email': 'john@example.com'});
        expect(result['name'], equals('John'));
        expect(result['email'], equals('john@example.com'));
      });

      test('omit method', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
          'email': z.string(),
        });

        final omittedSchema = schema.omit(['age']);
        final result =
            omittedSchema.parse({'name': 'John', 'email': 'john@example.com'});
        expect(result['name'], equals('John'));
        expect(result['email'], equals('john@example.com'));
      });

      test('keyof method', () {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
        });

        final keySchema = schema.keyof();
        expect(keySchema.parse('name'), equals('name'));
        expect(keySchema.parse('age'), equals('age'));
        expect(() => keySchema.parse('invalid'), throwsA(isA<ZardError>()));
      });

      test('refine validation', () {
        final schema = z.map({
          'password': z.string(),
          'confirmPassword': z.string(),
        }).refine(
          (value) => value['password'] == value['confirmPassword'],
          message: 'Passwords must match',
        );

        expect(
          schema.parse({'password': 'test123', 'confirmPassword': 'test123'}),
          isNotNull,
        );
        expect(
          () => schema
              .parse({'password': 'test123', 'confirmPassword': 'different'}),
          throwsA(isA<ZardError>()),
        );
      });

      test('async parsing', () async {
        final schema = z.map({
          'name': z.string(),
          'age': z.int(),
        });

        final result =
            await schema.parseAsync(Future.value({'name': 'John', 'age': 30}));
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });
    });

    group('ZEnum', () {
      test('basic validation', () {
        final schema = z.$enum(['red', 'green', 'blue']);
        expect(schema.parse('red'), equals('red'));
        expect(schema.parse('green'), equals('green'));
        expect(() => schema.parse('yellow'), throwsA(isA<ZardError>()));
      });

      test('type validation', () {
        final schema = z.$enum(['a', 'b', 'c']);
        expect(() => schema.parse(123), throwsA(isA<ZardError>()));
      });

      test('extract method', () {
        final schema = z.$enum(['a', 'b', 'c', 'd']).extract(['a', 'c']);
        expect(schema.parse('a'), equals('a'));
        expect(schema.parse('c'), equals('c'));
        expect(() => schema.parse('b'), throwsA(isA<ZardError>()));
      });

      test('exclude method', () {
        final schema = z.$enum(['a', 'b', 'c', 'd']).exclude(['b', 'd']);
        expect(schema.parse('a'), equals('a'));
        expect(schema.parse('c'), equals('c'));
        expect(() => schema.parse('b'), throwsA(isA<ZardError>()));
      });

      test('async parsing', () async {
        final schema = z.$enum(['red', 'green', 'blue']);
        expect(await schema.parseAsync(Future.value('red')), equals('red'));
      });

      test('safeParse', () {
        final schema = z.$enum(['red', 'green', 'blue']);
        final result = schema.safeParse('red');
        expect(result.success, isTrue);
        expect(result.data, equals('red'));

        final errorResult = schema.safeParse('yellow');
        expect(errorResult.success, isFalse);
        expect(errorResult.error, isA<ZardError>());
      });
    });

    group('ZInterface', () {
      test('basic validation', () {
        final schema = z.interface({
          'name': z.string(),
          'age': z.int(),
        });

        final result = schema.parse({'name': 'John', 'age': 30});
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('optional fields with ? suffix', () {
        final schema = z.interface({
          'name': z.string(),
          'age?': z.int(),
        });

        final result = schema.parse({'name': 'John'});
        expect(result['name'], equals('John'));
        expect(result.containsKey('age'), isFalse);
      });

      test('strict mode', () {
        final schema = z.interface({
          'name': z.string(),
        }).strict();

        expect(
          () => schema.parse({'name': 'John', 'extra': 'field'}),
          throwsA(isA<ZardError>()),
        );
      });

      test('nullable fields', () {
        final schema = z.interface({
          'name': z.string(),
          'age': z.int().nullable(),
        });

        final result = schema.parse({'name': 'John', 'age': null});
        expect(result['age'], isNull);
      });

      test('refine validation', () {
        final schema = z.interface({
          'min': z.int(),
          'max': z.int(),
        }).refine(
          (value) => value['min'] < value['max'],
          message: 'min must be less than max',
        );

        expect(schema.parse({'min': 5, 'max': 10}), isNotNull);
        expect(
          () => schema.parse({'min': 10, 'max': 5}),
          throwsA(isA<ZardError>()),
        );
      });

      test('async parsing', () async {
        final schema = z.interface({
          'name': z.string(),
          'age': z.int(),
        });

        final result =
            await schema.parseAsync(Future.value({'name': 'John', 'age': 30}));
        expect(result['name'], equals('John'));
      });
    });

    group('LazySchema', () {
      test('basic lazy evaluation', () {
        final lazySchema = z.lazy(() => z.string().min(3));

        expect(lazySchema.parse('hello'), equals('hello'));
        expect(() => lazySchema.parse('hi'), throwsA(isA<ZardError>()));
      });

      test('circular references', () {
        late Schema<Map<String, dynamic>> nodeSchema;

        nodeSchema = z.map({
          'value': z.string(),
          'children': z.list(z.lazy(() => nodeSchema)).optional(),
        });

        final result = nodeSchema.parse({
          'value': 'root',
          'children': [
            {'value': 'child1'},
            {
              'value': 'child2',
              'children': [
                {'value': 'grandchild'}
              ]
            }
          ]
        });

        expect(result['value'], equals('root'));
        expect(result['children'].length, equals(2));
      });

      test('async lazy parsing', () async {
        final lazySchema = z.lazy<String>(() => z.string().min(3));
        expect(await lazySchema.parseAsync(Future.value('hello')),
            equals('hello'));
      });
    });

    group('Schema Common Features', () {
      test('optional modifier', () {
        final schema = z.string().optional();
        expect(schema.isOptional, isTrue);
      });

      test('nullable modifier', () {
        final schema = z.string().nullable();
        expect(schema.isNullable, isTrue);
      });

      test('refine method', () {
        final schema = z.string().refine(
              (value) => value.length > 5,
              message: 'Must be longer than 5 characters',
            );

        expect(schema.parse('hello world'), equals('hello world'));
        expect(() => schema.parse('short'), throwsA(isA<ZardError>()));
      });

      test('transform method', () {
        final schema = z.string().transform((value) => value.length);
        expect(schema.parse('hello'), equals(5));
      });

      test('transformTyped method', () {
        final schema =
            z.int().transformTyped<double>((value) => value.toDouble());
        expect(schema.parse(42), equals(42.0));
      });

      test('list method', () {
        final schema = z.string().list();
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
      });

      test('safeParse success', () {
        final schema = z.string();
        final result = schema.safeParse('hello');
        expect(result.success, isTrue);
        expect(result.data, equals('hello'));
        expect(result.error, isNull);
      });

      test('safeParse error', () {
        final schema = z.string();
        final result = schema.safeParse(123);
        expect(result.success, isFalse);
        expect(result.data, isNull);
        expect(result.error, isA<ZardError>());
      });

      test('parseAsync with Future', () async {
        final schema = z.string();
        expect(await schema.parseAsync(Future.value('hello')), equals('hello'));
      });

      test('parseAsync with sync value', () async {
        final schema = z.string();
        expect(await schema.parseAsync('hello'), equals('hello'));
      });

      test('safeParseAsync success', () async {
        final schema = z.string();
        final result = await schema.safeParseAsync(Future.value('hello'));
        expect(result.success, isTrue);
        expect(result.data, equals('hello'));
      });

      test('safeParseAsync error', () async {
        final schema = z.string();
        final result = await schema.safeParseAsync(Future.value(123));
        expect(result.success, isFalse);
        expect(result.error, isA<ZardError>());
      });

      test('multiple transforms', () {
        final schema = z.string();
        schema.addTransform((value) => value.toUpperCase());
        schema.addTransform((value) => '$value!');

        expect(schema.parse('hello'), equals('HELLO!'));
      });

      test('validators are unmodifiable', () {
        final schema = z.string();
        final validators = schema.getValidators();
        expect(() => validators.add((value) => null), throwsUnsupportedError);
      });

      test('transforms are unmodifiable', () {
        final schema = z.string();
        final transforms = schema.getTransforms();
        expect(() => transforms.add((value) => value), throwsUnsupportedError);
      });

      test('errors are unmodifiable', () {
        final schema = z.string();
        final errors = schema.getErrors();
        expect(errors, isA<List<dynamic>>());
      });
    });

    group('Complex Scenarios', () {
      test('user registration form validation', () {
        final schema = z.map({
          'username': z.string().min(3).max(20),
          'email': z.string().email(),
          'password': z.string().min(8),
          'age': z.int().min(18).max(120),
          'website': z.string().url().optional(),
          'acceptTerms': z.bool(),
        });

        final validData = {
          'username': 'johndoe',
          'email': 'john@example.com',
          'password': 'secret123',
          'age': 25,
          'acceptTerms': true,
        };

        final result = schema.parse(validData);
        expect(result['username'], equals('johndoe'));
        expect(result['email'], equals('john@example.com'));
      });

      test('nested data structure', () {
        final addressSchema = z.map({
          'street': z.string(),
          'city': z.string(),
          'zipCode': z.string().regex(RegExp(r'^\d{5}$')),
        });

        final userSchema = z.map({
          'name': z.string(),
          'addresses': z.list(addressSchema).min(1),
          'primaryAddressIndex': z.int().min(0),
        });

        final data = {
          'name': 'John Doe',
          'addresses': [
            {'street': '123 Main St', 'city': 'New York', 'zipCode': '10001'},
            {'street': '456 Oak Ave', 'city': 'Boston', 'zipCode': '02101'},
          ],
          'primaryAddressIndex': 0,
        };

        final result = userSchema.parse(data);
        expect(result['name'], equals('John Doe'));
        expect(result['addresses'].length, equals(2));
      });

      test('API response validation', () {
        final responseSchema = z.map({
          'status': z.$enum(['success', 'error']),
          'data': z.map({
            'id': z.string().uuid(),
            'createdAt': z.string().datetime(),
            'items': z.list(z.int()).optional(),
          }).optional(),
          'error': z.string().optional(),
        }).refine(
          (value) => value['status'] == 'success'
              ? value.containsKey('data')
              : value.containsKey('error'),
          message:
              'Success status must have data, error status must have error message',
        );

        // ggignore - Example UUID for testing purposes only
        const exampleUuid = '123e4567-e89b-12d3-a456-426614174000';
        final successResponse = {
          'status': 'success',
          'data': {
            'id': exampleUuid,
            'createdAt': '2021-01-01T12:30:00Z',
            'items': [1, 2, 3],
          },
        };

        expect(responseSchema.parse(successResponse), isNotNull);
      });

      test('data transformation pipeline', () {
        final schema = z
            .string()
            .min(3)
            .transform((value) => value.toLowerCase())
            .transform((value) => value.trim())
            .transform((value) => value.replaceAll(' ', '-'));

        final result = schema.parse('  Hello World  ');
        expect(result, equals('hello-world'));
      });

      test('conditional validation with refine', () {
        final orderSchema = z.map({
          'hasDiscount': z.bool(),
          'discountCode': z.string().optional(),
          'total': z.double().positive(),
        }).refine(
          (value) => value['hasDiscount'] == true
              ? value.containsKey('discountCode')
              : true,
          message: 'Discount code is required when hasDiscount is true',
        );

        expect(
          orderSchema.parse({
            'hasDiscount': true,
            'discountCode': 'SAVE10',
            'total': 99.99,
          }),
          isNotNull,
        );

        expect(
          () => orderSchema.parse({
            'hasDiscount': true,
            'total': 99.99,
          }),
          throwsA(isA<ZardError>()),
        );
      });

      test('enum with extract and exclude', () {
        final allColors = z.$enum(['red', 'green', 'blue', 'yellow', 'orange']);

        final warmColors = allColors.extract(['red', 'yellow', 'orange']);
        expect(warmColors.parse('red'), equals('red'));
        expect(() => warmColors.parse('blue'), throwsA(isA<ZardError>()));

        final notGreen = allColors.exclude(['green']);
        expect(notGreen.parse('red'), equals('red'));
        expect(() => notGreen.parse('green'), throwsA(isA<ZardError>()));
      });

      test('map pick and omit', () {
        final userSchema = z.map({
          'id': z.string(),
          'name': z.string(),
          'email': z.string(),
          'password': z.string(),
          'createdAt': z.string(),
        });

        final publicUserSchema = userSchema.omit(['password']);
        final result = publicUserSchema.parse({
          'id': '123',
          'name': 'John',
          'email': 'john@example.com',
          'createdAt': '2021-01-01',
        });
        expect(result['name'], equals('John'));

        final loginSchema = userSchema.pick(['email', 'password']);
        final loginData = loginSchema.parse({
          'email': 'john@example.com',
          'password': 'secret',
        });
        expect(loginData['email'], equals('john@example.com'));
      });
    });

    group('Error Handling', () {
      test('error messages are descriptive', () {
        final schema = z.string().min(5);
        try {
          schema.parse('hi');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, contains('at least 5 characters'));
        }
      });

      test('custom error messages', () {
        final schema = z.string().min(5, message: 'Custom error!');
        try {
          schema.parse('hi');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((issue) => issue.message == 'Custom error!'),
              isTrue);
        }
      });

      test('multiple validation errors', () {
        final schema = z.map({
          'name': z.string().min(3),
          'age': z.int().positive(),
        });

        try {
          schema.parse({'name': 'Jo', 'age': -5});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.length, greaterThan(1));
        }
      });

      test('error with path information', () {
        final schema = z.map({
          'user': z.map({
            'name': z.string().min(3),
          }),
        });

        try {
          schema.parse({
            'user': {'name': 'Jo'}
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.path, isNotNull);
        }
      });
    });
  });
}
