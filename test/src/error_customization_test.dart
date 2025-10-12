import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('Error Customization Tests', () {
    group('Schema-level error customization', () {
      test('should use custom error map at schema level', () {
        final schema = ZString().errorMap((issue) {
          if (issue.type == 'type_error') {
            return 'Por favor, insira um texto válido';
          }
          return null;
        });

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, equals('Por favor, insira um texto válido'));
        }
      });

      test('should use default message when error map returns null', () {
        final schema = ZString().errorMap((issue) {
          return null; // Usa mensagem padrão
        });

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, contains('Expected a string'));
        }
      });

      test('should customize validation errors', () {
        final schema = ZString().min(5).errorMap((issue) {
          if (issue.type == 'min_error') {
            return 'Texto muito curto!';
          }
          return null;
        });

        try {
          schema.parse('hi');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message == 'Texto muito curto!'), isTrue);
        }
      });
    });

    group('Per-parse error customization', () {
      test('should use custom error map in parse', () {
        final schema = ZString();

        try {
          schema.parse(123, error: (issue) {
            return 'Erro customizado no parse';
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, equals('Erro customizado no parse'));
        }
      });

      test('should use custom error map in safeParse', () {
        final schema = ZInt();

        final result = schema.safeParse('not a number', error: (issue) {
          return 'Deve ser um número válido';
        });

        expect(result.success, isFalse);
        expect(result.error!.issues.first.message, equals('Deve ser um número válido'));
      });

      test('per-parse error map should override schema-level', () {
        final schema = ZString().errorMap((issue) {
          return 'Erro do schema';
        });

        try {
          schema.parse(123, error: (issue) {
            return 'Erro do parse';
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, equals('Erro do parse'));
        }
      });
    });

    group('Error map with different issue types', () {
      test('should distinguish between different error types', () {
        final schema = ZInt().min(10).max(100).errorMap((issue) {
          switch (issue.type) {
            case 'type_error':
              return 'Deve ser um número inteiro';
            case 'min_error':
              return 'Número muito pequeno';
            case 'max_error':
              return 'Número muito grande';
            default:
              return null;
          }
        });

        // Type error
        try {
          schema.parse('text');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.first.message, equals('Deve ser um número inteiro'));
        }

        // Min error
        try {
          schema.parse(5);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message == 'Número muito pequeno'), isTrue);
        }

        // Max error
        try {
          schema.parse(200);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message == 'Número muito grande'), isTrue);
        }
      });
    });

    group('Complex scenarios', () {
      test('should work with nested objects', () {
        final schema = ZMap({
          'name': ZString().errorMap((issue) => 'Nome inválido'),
          'age': ZInt().errorMap((issue) => 'Idade inválida'),
        });

        try {
          schema.parse({'name': 123, 'age': 'not a number'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message == 'Nome inválido'), isTrue);
          expect(error.issues.any((i) => i.message == 'Idade inválida'), isTrue);
        }
      });

      test('should work with arrays', () {
        final schema = ZList(ZString().errorMap((issue) => 'Item deve ser texto'));

        try {
          schema.parse(['valid', 123, 'another']);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message == 'Item deve ser texto'), isTrue);
        }
      });

      test('should integrate with prettifyError', () {
        final schema = ZMap({
          'email': ZString().email().errorMap((issue) => 'Email inválido'),
        });

        try {
          schema.parse({'email': 'not-an-email'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final pretty = prettifyError(error);
          expect(pretty, contains('Email inválido'));
        }
      });

      test('should integrate with flattenError', () {
        final schema = ZMap({
          'username': ZString().errorMap((issue) => 'Username customizado'),
          'password': ZString().errorMap((issue) => 'Password customizado'),
        });

        try {
          schema.parse({'username': 123, 'password': 456});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final flattened = flattenError(error);
          expect(flattened.fieldErrors['username']!.first, contains('Username customizado'));
          expect(flattened.fieldErrors['password']!.first, contains('Password customizado'));
        }
      });
    });

    group('Conditional error messages', () {
      test('should customize based on issue metadata', () {
        final schema = ZString().min(5).errorMap((issue) {
          if (issue.type == 'min_error') {
            // Pode acessar metadados do issue
            return 'Precisa ter pelo menos 5 caracteres';
          }
          return null;
        });

        try {
          schema.parse('ab');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;
          expect(error.issues.any((i) => i.message.contains('5 caracteres')), isTrue);
        }
      });
    });
  });
}
