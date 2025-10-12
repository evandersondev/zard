import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('Error Formatting Tests', () {
    group('treeifyError', () {
      test('should convert simple error to tree', () {
        final schema = ZMap({
          'username': ZString(),
          'age': ZInt(),
        });

        try {
          schema.parse({'username': 123, 'age': 'not a number'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final tree = treeifyError(error);

          expect(tree.errors, isEmpty);
          expect(tree.properties, isNotNull);
          expect(tree.properties!['username']!.errors, isNotEmpty);
          expect(tree.properties!['age']!.errors, isNotEmpty);
        }
      });

      test('should handle root level errors', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final tree = treeifyError(error);

          expect(tree.errors, isNotEmpty);
          expect(tree.properties, isNull);
        }
      });

      test('should handle nested object errors', () {
        final schema = ZMap({
          'user': ZMap({
            'name': ZString(),
            'email': ZString().email(),
          }),
        });

        try {
          schema.parse({
            'user': {
              'name': 123,
              'email': 'invalid-email',
            }
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final tree = treeifyError(error);

          expect(tree.properties, isNotNull);
          expect(tree.properties!['user'], isNotNull);
        }
      });

      test('should handle strict mode errors', () {
        final schema = ZMap({
          'name': ZString(),
        }).strict();

        try {
          schema.parse({'name': 'John', 'extra': 'field'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final tree = treeifyError(error);

          // O erro pode estar em errors ou em properties/items dependendo do path
          final hasErrors = tree.errors.isNotEmpty || tree.properties != null || tree.items != null;
          expect(hasErrors, isTrue);
        }
      });
    });

    group('prettifyError', () {
      test('should create readable error string', () {
        final schema = ZMap({
          'username': ZString(),
          'age': ZInt(),
        });

        try {
          schema.parse({'username': 123, 'age': 'not a number'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final pretty = prettifyError(error);

          expect(pretty, contains('✖'));
          expect(pretty, contains('username'));
          expect(pretty, contains('age'));
        }
      });

      test('should handle root level errors', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final pretty = prettifyError(error);

          expect(pretty, contains('✖'));
          expect(pretty, isNot(contains('→ at')));
        }
      });

      test('should show paths correctly', () {
        final schema = ZMap({
          'user': ZMap({
            'name': ZString(),
          }),
        });

        try {
          schema.parse({
            'user': {'name': 123}
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final pretty = prettifyError(error);

          expect(pretty, contains('→ at'));
          expect(pretty, contains('user.name'));
        }
      });
    });

    group('flattenError', () {
      test('should flatten errors to field level', () {
        final schema = ZMap({
          'username': ZString(),
          'age': ZInt(),
        });

        try {
          schema.parse({'username': 123, 'age': 'not a number'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final flattened = flattenError(error);

          expect(flattened.formErrors, isEmpty);
          expect(flattened.fieldErrors, isNotEmpty);
          expect(flattened.fieldErrors['username'], isNotNull);
          expect(flattened.fieldErrors['age'], isNotNull);
        }
      });

      test('should separate form and field errors', () {
        final schema = ZMap({
          'name': ZString(),
        }).strict();

        try {
          schema.parse({'name': 'John', 'extra': 'field'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final flattened = flattenError(error);

          // Erros podem estar em formErrors ou fieldErrors
          final hasErrors = flattened.formErrors.isNotEmpty || flattened.fieldErrors.isNotEmpty;
          expect(hasErrors, isTrue);
        }
      });

      test('should handle nested paths by taking first segment', () {
        final schema = ZMap({
          'user': ZMap({
            'name': ZString(),
            'email': ZString(),
          }),
        });

        try {
          schema.parse({
            'user': {
              'name': 123,
              'email': 456,
            }
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final flattened = flattenError(error);

          // Ambos erros devem estar agrupados sob 'user'
          expect(flattened.fieldErrors['user'], isNotNull);
          expect(flattened.fieldErrors['user']!.length, greaterThanOrEqualTo(1));
        }
      });
    });

    group('Complex Scenarios', () {
      test('should handle array validation errors', () {
        final schema = ZMap({
          'tags': ZList(ZString()),
        });

        try {
          schema.parse({
            'tags': ['valid', 123, 'another'],
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          // Verifica que os erros existem
          expect(error.issues, isNotEmpty);

          // Testa formatação
          final tree = treeifyError(error);
          expect(tree, isNotNull);

          final flattened = flattenError(error);
          // Pode estar em fieldErrors ou formErrors
          final hasErrors = flattened.fieldErrors.isNotEmpty || flattened.formErrors.isNotEmpty;
          expect(hasErrors, isTrue);

          final pretty = prettifyError(error);
          expect(pretty, contains('✖'));
        }
      });

      test('should handle multiple errors on same field', () {
        final schema = ZMap({
          'password': ZString().min(8).regex(RegExp(r'[A-Z]')),
        });

        try {
          schema.parse({'password': 'short'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final flattened = flattenError(error);
          expect(flattened.fieldErrors['password'], isNotNull);
          // Pode ter múltiplos erros
          expect(flattened.fieldErrors['password']!.length, greaterThanOrEqualTo(1));
        }
      });

      test('should format complex nested structure', () {
        final schema = ZMap({
          'user': ZMap({
            'profile': ZMap({
              'name': ZString(),
              'age': ZInt().positive(),
            }),
            'contacts': ZList(ZString().email()),
          }),
        });

        try {
          schema.parse({
            'user': {
              'profile': {
                'name': 123,
                'age': -5,
              },
              'contacts': ['valid@email.com', 'invalid-email'],
            }
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final tree = treeifyError(error);
          expect(tree.properties, isNotNull);
          expect(tree.properties!['user'], isNotNull);

          final flattened = flattenError(error);
          expect(flattened.fieldErrors, isNotEmpty);

          final pretty = prettifyError(error);
          expect(pretty, contains('✖'));
          expect(pretty, contains('→ at'));
        }
      });
    });

    group('Integration with existing error handling', () {
      test('should work with safeParse results', () {
        final schema = ZMap({
          'email': ZString().email(),
          'age': ZInt().min(18),
        });

        final result = schema.safeParse({
          'email': 'invalid',
          'age': 15,
        });

        expect(result.success, isFalse);
        expect(result.error, isNotNull);

        final flattened = flattenError(result.error!);
        expect(flattened.fieldErrors['email'], isNotNull);
        expect(flattened.fieldErrors['age'], isNotNull);
      });

      test('should integrate with custom error messages', () {
        final schema = ZString(message: 'Campo obrigatório deve ser texto');

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final pretty = prettifyError(error);
          expect(pretty, contains('Campo obrigatório deve ser texto'));
        }
      });
    });
  });
}
