import 'package:test/test.dart';
import 'package:zard/src/schemas/schemas.dart';
import 'package:zard/src/schemas/z_lazy.dart';
import 'package:zard/src/types/zard_error.dart';

void main() {
  group('Schemas Integration Tests', () {
    group('ZString', () {
      test('basic validation', () {
        final schema = ZString();
        expect(schema.parse('hello'), equals('hello'));
        expect(() => schema.parse(123), throwsA(isA<ZardError>()));
        expect(() => schema.parse(null), throwsA(isA<ZardError>()));
      });

      test('min and max', () {
        final schema = ZString().min(3).max(10);
        expect(schema.parse('hello'), equals('hello'));
        expect(() => schema.parse('hi'), throwsA(isA<ZardError>()));
        expect(() => schema.parse('hello world!'), throwsA(isA<ZardError>()));
      });

      test('email validation', () {
        final schema = ZString().email();
        expect(schema.parse('test@example.com'), equals('test@example.com'));
        expect(() => schema.parse('invalid'), throwsA(isA<ZardError>()));
      });

      test('url validation', () {
        final schema = ZString().url();
        expect(schema.parse('https://example.com'), equals('https://example.com'));
        expect(() => schema.parse('invalid'), throwsA(isA<ZardError>()));
      });

      test('uuid validation', () {
        final schema = ZString().uuid();
        expect(
          schema.parse('123e4567-e89b-12d3-a456-426614174000'),
          equals('123e4567-e89b-12d3-a456-426614174000'),
        );
        expect(() => schema.parse('invalid-uuid'), throwsA(isA<ZardError>()));
      });

      test('startsWith and endsWith', () {
        final schema = ZString().startsWith('Hello').endsWith('world');
        expect(schema.parse('Hello world'), equals('Hello world'));
        expect(() => schema.parse('world Hello'), throwsA(isA<ZardError>()));
      });

      test('contains', () {
        final schema = ZString().contains('test');
        expect(schema.parse('this is a test'), equals('this is a test'));
        expect(() => schema.parse('no match'), throwsA(isA<ZardError>()));
      });

      test('regex validation', () {
        final schema = ZString().regex(RegExp(r'^[a-z]+$'));
        expect(schema.parse('hello'), equals('hello'));
        expect(() => schema.parse('Hello'), throwsA(isA<ZardError>()));
      });

      test('datetime, date, time validation', () {
        expect(
          ZString().datetime().parse('2021-01-01T12:30:00Z'),
          equals('2021-01-01T12:30:00Z'),
        );
        expect(ZString().date().parse('2021-01-01'), equals('2021-01-01'));
        expect(ZString().time().parse('12:00:00'), equals('12:00:00'));
      });

      test('ZCoerceString', () {
        final schema = ZCoerceString();
        expect(schema.parse(123), equals('123'));
        expect(schema.parse(true), equals('true'));
        expect(schema.parse(null), equals('null'));
      });
    });

    group('ZBool', () {
      test('basic validation', () {
        final schema = ZBool();
        expect(schema.parse(true), isTrue);
        expect(schema.parse(false), isFalse);
        expect(() => schema.parse('true'), throwsA(isA<ZardError>()));
        expect(() => schema.parse(1), throwsA(isA<ZardError>()));
      });

      test('async parsing', () async {
        final schema = ZBool();
        expect(await schema.parseAsync(Future.value(true)), isTrue);
        expect(await schema.parseAsync(false), isFalse);
      });

      test('ZCoerceBoolean', () {
        final schema = ZCoerceBoolean();
        expect(schema.parse(0), isFalse);
        expect(schema.parse('0'), isFalse);
        expect(schema.parse(''), isFalse);
        expect(schema.parse(false), isFalse);
        expect(schema.parse(null), isFalse);
        expect(schema.parse(1), isTrue);
        expect(schema.parse('hello'), isTrue);
      });
    });

    group('ZInt', () {
      test('basic validation', () {
        final schema = ZInt();
        expect(schema.parse(42), equals(42));
        expect(() => schema.parse(3.14), throwsA(isA<ZardError>()));
        expect(() => schema.parse('42'), throwsA(isA<ZardError>()));
      });

      test('min and max', () {
        final schema = ZInt().min(0).max(100);
        expect(schema.parse(50), equals(50));
        expect(() => schema.parse(-1), throwsA(isA<ZardError>()));
        expect(() => schema.parse(101), throwsA(isA<ZardError>()));
      });

      test('positive, nonnegative, negative', () {
        expect(ZInt().positive().parse(5), equals(5));
        expect(() => ZInt().positive().parse(0), throwsA(isA<ZardError>()));

        expect(ZInt().nonnegative().parse(0), equals(0));
        expect(() => ZInt().nonnegative().parse(-1), throwsA(isA<ZardError>()));

        expect(ZInt().negative().parse(-5), equals(-5));
        expect(() => ZInt().negative().parse(0), throwsA(isA<ZardError>()));
      });

      test('multipleOf and step', () {
        final schema = ZInt().multipleOf(3);
        expect(schema.parse(6), equals(6));
        expect(() => schema.parse(5), throwsA(isA<ZardError>()));

        final stepSchema = ZInt().step(5);
        expect(stepSchema.parse(10), equals(10));
        expect(() => stepSchema.parse(7), throwsA(isA<ZardError>()));
      });

      test('ZCoerceInt', () {
        final schema = ZCoerceInt();
        expect(schema.parse('42'), equals(42));
        expect(schema.parse(42), equals(42));
        expect(() => schema.parse('not a number'), throwsA(isA<ZardError>()));
      });
    });

    group('ZDouble', () {
      test('basic validation', () {
        final schema = ZDouble();
        expect(schema.parse(3.14), equals(3.14));
        expect(() => schema.parse(42), throwsA(isA<ZardError>()));
        expect(() => schema.parse('3.14'), throwsA(isA<ZardError>()));
      });

      test('min and max', () {
        final schema = ZDouble().min(0.0).max(10.0);
        expect(schema.parse(5.5), equals(5.5));
        expect(() => schema.parse(-0.1), throwsA(isA<ZardError>()));
        expect(() => schema.parse(10.1), throwsA(isA<ZardError>()));
      });

      test('positive, nonnegative, negative', () {
        expect(ZDouble().positive().parse(5.5), equals(5.5));
        expect(() => ZDouble().positive().parse(0.0), throwsA(isA<ZardError>()));

        expect(ZDouble().nonnegative().parse(0.0), equals(0.0));
        expect(() => ZDouble().nonnegative().parse(-0.1), throwsA(isA<ZardError>()));

        expect(ZDouble().negative().parse(-5.5), equals(-5.5));
        expect(() => ZDouble().negative().parse(0.0), throwsA(isA<ZardError>()));
      });

      test('multipleOf and step', () {
        final schema = ZDouble().multipleOf(0.5);
        expect(schema.parse(1.5), equals(1.5));
        expect(() => schema.parse(1.3), throwsA(isA<ZardError>()));
      });

      test('ZCoerceDouble', () {
        final schema = ZCoerceDouble();
        expect(schema.parse('3.14'), equals(3.14));
        expect(schema.parse(3.14), equals(3.14));
        expect(() => schema.parse('not a number'), throwsA(isA<ZardError>()));
      });
    });

    group('ZList', () {
      test('basic validation', () {
        final schema = ZList(ZString());
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse('not a list'), throwsA(isA<ZardError>()));
      });

      test('validates items', () {
        final schema = ZList(ZInt());
        expect(schema.parse([1, 2, 3]), equals([1, 2, 3]));
        expect(() => schema.parse([1, 'two', 3]), throwsA(isA<ZardError>()));
      });

      test('min and max length', () {
        final schema = ZList(ZString()).min(2).max(5);
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse(['a']), throwsA(isA<ZardError>()));
        expect(() => schema.parse(['a', 'b', 'c', 'd', 'e', 'f']), throwsA(isA<ZardError>()));
      });

      test('noempty validation', () {
        final schema = ZList(ZString()).noempty();
        expect(schema.parse(['a']), equals(['a']));
        expect(() => schema.parse([]), throwsA(isA<ZardError>()));
      });

      test('exact length', () {
        final schema = ZList(ZString()).lenght(3);
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(() => schema.parse(['a', 'b']), throwsA(isA<ZardError>()));
      });

      test('nested lists', () {
        final schema = ZList(ZList(ZInt()));
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
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
        });

        final result = schema.parse({'name': 'John', 'age': 30});
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('validates required fields', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
        });

        expect(() => schema.parse({'name': 'John'}), throwsA(isA<ZardError>()));
      });

      test('optional fields', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt().optional(),
        });

        final result = schema.parse({'name': 'John'});
        expect(result['name'], equals('John'));
        expect(result.containsKey('age'), isFalse);
      });

      test('nullable fields', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt().nullable(),
        });

        final result = schema.parse({'name': 'John', 'age': null});
        expect(result['name'], equals('John'));
        expect(result['age'], isNull);
      });

      test('strict mode', () {
        final schema = ZMap({
          'name': ZString(),
        }).strict();

        expect(() => schema.parse({'name': 'John', 'extra': 'field'}), throwsA(isA<ZardError>()));
      });

      test('nested maps', () {
        final schema = ZMap({
          'user': ZMap({
            'name': ZString(),
            'email': ZString().email(),
          }),
        });

        final result = schema.parse({
          'user': {'name': 'John', 'email': 'john@example.com'}
        });
        expect(result['user']['name'], equals('John'));
      });

      test('pick method', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
          'email': ZString(),
        });

        final pickedSchema = schema.pick(['name', 'email']);
        final result = pickedSchema.parse({'name': 'John', 'email': 'john@example.com'});
        expect(result['name'], equals('John'));
        expect(result['email'], equals('john@example.com'));
      });

      test('omit method', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
          'email': ZString(),
        });

        final omittedSchema = schema.omit(['age']);
        final result = omittedSchema.parse({'name': 'John', 'email': 'john@example.com'});
        expect(result['name'], equals('John'));
        expect(result['email'], equals('john@example.com'));
      });

      test('keyof method', () {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
        });

        final keySchema = schema.keyof();
        expect(keySchema.parse('name'), equals('name'));
        expect(keySchema.parse('age'), equals('age'));
        expect(() => keySchema.parse('invalid'), throwsA(isA<ZardError>()));
      });

      test('refine validation', () {
        final schema = ZMap({
          'password': ZString(),
          'confirmPassword': ZString(),
        }).refine(
          (value) => value['password'] == value['confirmPassword'],
          message: 'Passwords must match',
        );

        expect(
          schema.parse({'password': 'test123', 'confirmPassword': 'test123'}),
          isNotNull,
        );
        expect(
          () => schema.parse({'password': 'test123', 'confirmPassword': 'different'}),
          throwsA(isA<ZardError>()),
        );
      });

      test('async parsing', () async {
        final schema = ZMap({
          'name': ZString(),
          'age': ZInt(),
        });

        final result = await schema.parseAsync(Future.value({'name': 'John', 'age': 30}));
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });
    });

    group('ZDate', () {
      test('basic validation', () {
        final schema = ZDate();
        final now = DateTime.now();
        expect(schema.parse(now), equals(now));
      });

      test('string parsing', () {
        final schema = ZDate();
        final result = schema.parse('2021-01-01T12:30:00Z');
        expect(result, isA<DateTime>());
        expect(result.year, equals(2021));
      });

      test('datetime validation', () {
        final schema = ZDate().datetime();
        expect(schema.parse('2021-01-01T12:30:00Z'), isA<DateTime>());
        expect(() => schema.parse('invalid'), throwsA(isA<ZardError>()));
      });

      test('ZCoerceDate', () {
        final schema = ZCoerceDate();
        final result = schema.parse('2021-01-01');
        expect(result, isA<DateTime>());
        expect(result.year, equals(2021));
      });
    });

    group('ZEnum', () {
      test('basic validation', () {
        final schema = ZEnum(['red', 'green', 'blue']);
        expect(schema.parse('red'), equals('red'));
        expect(schema.parse('green'), equals('green'));
        expect(() => schema.parse('yellow'), throwsA(isA<ZardError>()));
      });

      test('type validation', () {
        final schema = ZEnum(['a', 'b', 'c']);
        expect(() => schema.parse(123), throwsA(isA<ZardError>()));
      });

      test('extract method', () {
        final schema = ZEnum(['a', 'b', 'c', 'd']).extract(['a', 'c']);
        expect(schema.parse('a'), equals('a'));
        expect(schema.parse('c'), equals('c'));
        expect(() => schema.parse('b'), throwsA(isA<ZardError>()));
      });

      test('exclude method', () {
        final schema = ZEnum(['a', 'b', 'c', 'd']).exclude(['b', 'd']);
        expect(schema.parse('a'), equals('a'));
        expect(schema.parse('c'), equals('c'));
        expect(() => schema.parse('b'), throwsA(isA<ZardError>()));
      });

      test('async parsing', () async {
        final schema = ZEnum(['red', 'green', 'blue']);
        expect(await schema.parseAsync(Future.value('red')), equals('red'));
      });

      test('safeParse', () {
        final schema = ZEnum(['red', 'green', 'blue']);
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
        final schema = ZInterface({
          'name': ZString(),
          'age': ZInt(),
        });

        final result = schema.parse({'name': 'John', 'age': 30});
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('optional fields with ? suffix', () {
        final schema = ZInterface({
          'name': ZString(),
          'age?': ZInt(),
        });

        final result = schema.parse({'name': 'John'});
        expect(result['name'], equals('John'));
        expect(result.containsKey('age'), isFalse);
      });

      test('strict mode', () {
        final schema = ZInterface({
          'name': ZString(),
        }).strict();

        expect(
          () => schema.parse({'name': 'John', 'extra': 'field'}),
          throwsA(isA<ZardError>()),
        );
      });

      test('nullable fields', () {
        final schema = ZInterface({
          'name': ZString(),
          'age': ZInt().nullable(),
        });

        final result = schema.parse({'name': 'John', 'age': null});
        expect(result['age'], isNull);
      });

      test('refine validation', () {
        final schema = ZInterface({
          'min': ZInt(),
          'max': ZInt(),
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
        final schema = ZInterface({
          'name': ZString(),
          'age': ZInt(),
        });

        final result = await schema.parseAsync(Future.value({'name': 'John', 'age': 30}));
        expect(result['name'], equals('John'));
      });
    });

    group('LazySchema', () {
      test('basic lazy evaluation', () {
        late Schema<String> lazySchema;
        lazySchema = LazySchema<String>(() => ZString().min(3));

        expect(lazySchema.parse('hello'), equals('hello'));
        expect(() => lazySchema.parse('hi'), throwsA(isA<ZardError>()));
      });

      test('circular references', () {
        late Schema<Map<String, dynamic>> nodeSchema;

        nodeSchema = ZMap({
          'value': ZString(),
          'children': ZList(LazySchema(() => nodeSchema)).optional(),
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
        final lazySchema = LazySchema<String>(() => ZString().min(3));
        expect(await lazySchema.parseAsync(Future.value('hello')), equals('hello'));
      });
    });

    group('Schema Common Features', () {
      test('optional modifier', () {
        final schema = ZString().optional();
        expect(schema.isOptional, isTrue);
      });

      test('nullable modifier', () {
        final schema = ZString().nullable();
        expect(schema.isNullable, isTrue);
      });

      test('refine method', () {
        final schema = ZString().refine(
          (value) => value.length > 5,
          message: 'Must be longer than 5 characters',
        );

        expect(schema.parse('hello world'), equals('hello world'));
        expect(() => schema.parse('short'), throwsA(isA<ZardError>()));
      });

      test('transform method', () {
        final schema = ZString().transform((value) => value.length);
        expect(schema.parse('hello'), equals(5));
      });

      test('transformTyped method', () {
        final schema = ZInt().transformTyped<double>((value) => value.toDouble());
        expect(schema.parse(42), equals(42.0));
      });

      test('list method', () {
        final schema = ZString().list();
        expect(schema.parse(['a', 'b', 'c']), equals(['a', 'b', 'c']));
      });

      test('safeParse success', () {
        final schema = ZString();
        final result = schema.safeParse('hello');
        expect(result.success, isTrue);
        expect(result.data, equals('hello'));
        expect(result.error, isNull);
      });

      test('safeParse error', () {
        final schema = ZString();
        final result = schema.safeParse(123);
        expect(result.success, isFalse);
        expect(result.data, isNull);
        expect(result.error, isA<ZardError>());
      });

      test('parseAsync with Future', () async {
        final schema = ZString();
        expect(await schema.parseAsync(Future.value('hello')), equals('hello'));
      });

      test('parseAsync with sync value', () async {
        final schema = ZString();
        expect(await schema.parseAsync('hello'), equals('hello'));
      });

      test('safeParseAsync success', () async {
        final schema = ZString();
        final result = await schema.safeParseAsync(Future.value('hello'));
        expect(result.success, isTrue);
        expect(result.data, equals('hello'));
      });

      test('safeParseAsync error', () async {
        final schema = ZString();
        final result = await schema.safeParseAsync(Future.value(123));
        expect(result.success, isFalse);
        expect(result.error, isA<ZardError>());
      });

      test('multiple transforms', () {
        final schema = ZString();
        schema.addTransform((value) => value.toUpperCase());
        schema.addTransform((value) => '$value!');

        expect(schema.parse('hello'), equals('HELLO!'));
      });

      test('validators are unmodifiable', () {
        final schema = ZString();
        final validators = schema.getValidators();
        expect(() => validators.add((value) => null), throwsUnsupportedError);
      });

      test('transforms are unmodifiable', () {
        final schema = ZString();
        final transforms = schema.getTransforms();
        expect(() => transforms.add((value) => value), throwsUnsupportedError);
      });

      test('errors are unmodifiable', () {
        final schema = ZString();
        final errors = schema.getErrors();
        expect(errors, isA<List<dynamic>>());
      });
    });

    group('Complex Scenarios', () {
      test('user registration form validation', () {
        final schema = ZMap({
          'username': ZString().min(3).max(20),
          'email': ZString().email(),
          'password': ZString().min(8),
          'age': ZInt().min(18).max(120),
          'website': ZString().url().optional(),
          'acceptTerms': ZBool(),
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
        final addressSchema = ZMap({
          'street': ZString(),
          'city': ZString(),
          'zipCode': ZString().regex(RegExp(r'^\d{5}$')),
        });

        final userSchema = ZMap({
          'name': ZString(),
          'addresses': ZList(addressSchema).min(1),
          'primaryAddressIndex': ZInt().min(0),
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
        final responseSchema = ZMap({
          'status': ZEnum(['success', 'error']),
          'data': ZMap({
            'id': ZString().uuid(),
            'createdAt': ZString().datetime(),
            'items': ZList(ZInt()).optional(),
          }).optional(),
          'error': ZString().optional(),
        }).refine(
          (value) => value['status'] == 'success' ? value.containsKey('data') : value.containsKey('error'),
          message: 'Success status must have data, error status must have error message',
        );

        final successResponse = {
          'status': 'success',
          'data': {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'createdAt': '2021-01-01T12:30:00Z',
            'items': [1, 2, 3],
          },
        };

        expect(responseSchema.parse(successResponse), isNotNull);
      });

      test('data transformation pipeline', () {
        final schema = ZString().min(3).transform((value) => value.toLowerCase()).transform((value) => value.trim()).transform((value) => value.replaceAll(' ', '-'));

        final result = schema.parse('  Hello World  ');
        expect(result, equals('hello-world'));
      });

      test('conditional validation with refine', () {
        final orderSchema = ZMap({
          'hasDiscount': ZBool(),
          'discountCode': ZString().optional(),
          'total': ZDouble().positive(),
        }).refine(
          (value) => value['hasDiscount'] == true ? value.containsKey('discountCode') : true,
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
        final allColors = ZEnum(['red', 'green', 'blue', 'yellow', 'orange']);

        final warmColors = allColors.extract(['red', 'yellow', 'orange']);
        expect(warmColors.parse('red'), equals('red'));
        expect(() => warmColors.parse('blue'), throwsA(isA<ZardError>()));

        final notGreen = allColors.exclude(['green']);
        expect(notGreen.parse('red'), equals('red'));
        expect(() => notGreen.parse('green'), throwsA(isA<ZardError>()));
      });

      test('map pick and omit', () {
        final userSchema = ZMap({
          'id': ZString(),
          'name': ZString(),
          'email': ZString(),
          'password': ZString(),
          'createdAt': ZString(),
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
        final schema = ZString().min(5);
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
        final schema = ZString().min(5, message: 'Custom error!');
        try {
          schema.parse('hi');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((issue) => issue.message == 'Custom error!'), isTrue);
        }
      });

      test('multiple validation errors', () {
        final schema = ZMap({
          'name': ZString().min(3),
          'age': ZInt().positive(),
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
        final schema = ZMap({
          'user': ZMap({
            'name': ZString().min(3),
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
