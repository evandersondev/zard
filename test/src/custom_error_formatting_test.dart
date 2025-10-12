import 'package:test/test.dart';
import 'package:zard/zard.dart';

/// Formata erros com emojis e cores customizadas
String prettifyErrorWithEmoji(ZardError error, {String emoji = '❌'}) {
  final buffer = StringBuffer();

  for (var i = 0; i < error.issues.length; i++) {
    final issue = error.issues[i];
    buffer.write('$emoji ${issue.message}');

    if (issue.path != null && issue.path!.isNotEmpty) {
      buffer.write('\n  ↳ Campo: ${issue.path}');
      buffer.write('\n  ↳ Tipo: ${issue.type}');
    }

    if (i < error.issues.length - 1) {
      buffer.write('\n\n');
    }
  }

  return buffer.toString();
}

/// Formata erros em estilo caixa
String prettifyErrorBoxed(ZardError error) {
  final buffer = StringBuffer();
  buffer.writeln('╔═══════════════════════════════════════╗');
  buffer.writeln('║  ERROS DE VALIDAÇÃO                   ║');
  buffer.writeln('╚═══════════════════════════════════════╝\n');

  for (var i = 0; i < error.issues.length; i++) {
    final issue = error.issues[i];
    buffer.write('${i + 1}. ${issue.message}');

    if (issue.path != null && issue.path!.isNotEmpty) {
      buffer.write('\n   📍 Localização: ${issue.path}');
    }

    buffer.write('\n   🏷️  Tipo: ${_translateErrorType(issue.type)}');
    buffer.write('\n');
  }

  return buffer.toString();
}

String _translateErrorType(String type) {
  const translations = {
    'type_error': 'Tipo Inválido',
    'min_error': 'Valor Mínimo',
    'max_error': 'Valor Máximo',
    'email_error': 'Email Inválido',
    'required_error': 'Campo Obrigatório',
    'strict_error': 'Campo Extra',
  };
  return translations[type] ?? type;
}

/// Formata erros como JSON para APIs
Map<String, dynamic> prettifyErrorJson(ZardError error) {
  return {
    'status': 'error',
    'timestamp': DateTime.now().toIso8601String(),
    'errors': error.issues
        .map((issue) => {
              'message': issue.message,
              'field': issue.path,
              'code': issue.type,
              'value': issue.value?.toString(),
            })
        .toList(),
    'count': error.issues.length,
  };
}

/// Formata erros com severidade
class ErrorDisplay {
  final String message;
  final String field;
  final String severity;
  final String icon;

  ErrorDisplay({
    required this.message,
    required this.field,
    required this.severity,
    required this.icon,
  });

  @override
  String toString() {
    return '$icon [$severity] $message (campo: $field)';
  }
}

List<ErrorDisplay> prettifyErrorWithSeverity(ZardError error) {
  return error.issues.map((issue) {
    return ErrorDisplay(
      message: issue.message,
      field: issue.path ?? 'geral',
      severity: _getSeverity(issue.type),
      icon: _getIcon(issue.type),
    );
  }).toList();
}

String _getSeverity(String type) {
  if (type == 'required_error') return 'CRÍTICO';
  if (type == 'type_error') return 'ERRO';
  return 'AVISO';
}

String _getIcon(String type) {
  const icons = {
    'required_error': '⛔',
    'type_error': '❌',
    'min_error': '⬇️',
    'max_error': '⬆️',
    'email_error': '📧',
    'url_error': '🔗',
  };
  return icons[type] ?? '⚠️';
}

void main() {
  group('Custom Error Formatting Tests', () {
    group('prettifyErrorWithEmoji', () {
      test('should format with custom emoji', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final formatted = prettifyErrorWithEmoji(error, emoji: '⚠️');
          expect(formatted, contains('⚠️'));
          expect(formatted, contains('Expected a string'));
        }
      });

      test('should show path and type', () {
        final schema = ZMap({
          'username': ZString(),
        });

        try {
          schema.parse({'username': 123});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final formatted = prettifyErrorWithEmoji(error);
          expect(formatted, contains('Campo:'));
          expect(formatted, contains('Tipo:'));
        }
      });

      test('should separate multiple errors', () {
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

          final formatted = prettifyErrorWithEmoji(error);
          final lines = formatted.split('\n\n');
          expect(lines.length, greaterThan(1));
        }
      });
    });

    group('prettifyErrorBoxed', () {
      test('should create boxed format', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final formatted = prettifyErrorBoxed(error);
          expect(formatted, contains('╔═══'));
          expect(formatted, contains('ERROS DE VALIDAÇÃO'));
          expect(formatted, contains('╚═══'));
        }
      });

      test('should translate error types to Portuguese', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final formatted = prettifyErrorBoxed(error);
          expect(formatted, contains('Tipo Inválido'));
        }
      });

      test('should number errors', () {
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

          final formatted = prettifyErrorBoxed(error);
          expect(formatted, contains('1.'));
          expect(formatted, contains('2.'));
        }
      });
    });

    group('prettifyErrorJson', () {
      test('should create JSON structure', () {
        final schema = ZString();

        try {
          schema.parse(123);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final json = prettifyErrorJson(error);
          expect(json['status'], equals('error'));
          expect(json['timestamp'], isNotNull);
          expect(json['errors'], isList);
          expect(json['count'], equals(1));
        }
      });

      test('should include all error details', () {
        final schema = ZMap({
          'email': ZString().email(),
        });

        try {
          schema.parse({'email': 'invalid'});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final json = prettifyErrorJson(error);
          final firstError = json['errors'][0];

          expect(firstError['message'], isNotNull);
          expect(firstError['field'], isNotNull);
          expect(firstError['code'], isNotNull);
        }
      });
    });

    group('prettifyErrorWithSeverity', () {
      test('should assign severity levels', () {
        final schema = ZMap({
          'name': ZString(),
        });

        try {
          schema.parse({});
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final displays = prettifyErrorWithSeverity(error);
          expect(displays, isNotEmpty);
          expect(displays.first.severity, equals('CRÍTICO'));
        }
      });

      test('should assign appropriate icons', () {
        final schema = ZString().email();

        try {
          schema.parse('invalid');
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final displays = prettifyErrorWithSeverity(error);
          expect(displays.any((d) => d.icon == '📧'), isTrue);
        }
      });

      test('should format as readable string', () {
        final schema = ZInt().min(10);

        try {
          schema.parse(5);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          final displays = prettifyErrorWithSeverity(error);
          final formatted = displays.first.toString();

          expect(formatted, contains('⬇️'));
          expect(formatted, contains('AVISO'));
        }
      });
    });

    group('Real-world scenarios', () {
      test('user registration form with custom formatting', () {
        final schema = ZMap({
          'username': ZString().min(3).errorMap((issue) {
            if (issue.type == 'min_error') {
              return 'Nome de usuário muito curto';
            }
            return null;
          }),
          'email': ZString().email().errorMap((issue) => 'Email inválido'),
          'password': ZString().min(8).errorMap((issue) {
            if (issue.type == 'min_error') {
              return 'Senha deve ter no mínimo 8 caracteres';
            }
            return null;
          }),
        });

        try {
          schema.parse({
            'username': 'ab',
            'email': 'invalid',
            'password': '123',
          });
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<ZardError>());
          final error = e as ZardError;

          // Testa formatação com emoji
          final emojiFormat = prettifyErrorWithEmoji(error, emoji: '🚨');
          expect(emojiFormat, contains('🚨'));
          expect(emojiFormat, contains('Nome de usuário muito curto'));

          // Testa formatação boxed
          final boxedFormat = prettifyErrorBoxed(error);
          expect(boxedFormat, contains('╔═══'));

          // Testa formatação JSON
          final jsonFormat = prettifyErrorJson(error);
          expect(jsonFormat['count'], greaterThan(0));

          // Testa formatação com severidade
          final severityFormat = prettifyErrorWithSeverity(error);
          expect(severityFormat.length, greaterThan(0));
        }
      });

      test('API response with flattened errors', () {
        final schema = ZMap({
          'user': ZMap({
            'name': ZString(),
            'email': ZString().email(),
          }),
          'settings': ZMap({
            'notifications': ZBool(),
          }),
        });

        final result = schema.safeParse({
          'user': {
            'name': 123,
            'email': 'invalid',
          },
          'settings': {
            'notifications': 'yes',
          },
        });

        expect(result.success, isFalse);

        // Formato JSON para API
        final jsonResponse = prettifyErrorJson(result.error!);
        expect(jsonResponse['status'], equals('error'));
        expect(jsonResponse['errors'], isList);

        // Formato flatten para formulário
        final flattened = flattenError(result.error!);
        expect(flattened.fieldErrors, isNotEmpty);
      });

      test('combining error maps with custom formatters', () {
        final schema = ZMap({
          'age': ZInt().min(18).max(120).errorMap((issue) {
            if (issue.type == 'min_error') {
              return '🔞 Você deve ter pelo menos 18 anos';
            }
            if (issue.type == 'max_error') {
              return '👴 Idade máxima é 120 anos';
            }
            if (issue.type == 'type_error') {
              return '🔢 Idade deve ser um número';
            }
            return null;
          }),
        });

        // Teste min error
        try {
          schema.parse({'age': 15});
          fail('Should have thrown');
        } catch (e) {
          final error = e as ZardError;
          final formatted = prettifyErrorBoxed(error);
          expect(formatted, contains('🔞 Você deve ter pelo menos 18 anos'));
        }

        // Teste type error
        try {
          schema.parse({'age': 'text'});
          fail('Should have thrown');
        } catch (e) {
          final error = e as ZardError;
          final displays = prettifyErrorWithSeverity(error);
          expect(displays.first.message, contains('🔢 Idade deve ser um número'));
        }
      });

      test('multilevel nested errors with tree format', () {
        final schema = ZMap({
          'company': ZMap({
            'name': ZString(),
            'address': ZMap({
              'street': ZString(),
              'city': ZString(),
              'zipCode': ZString().regex(RegExp(r'^\d{5}$')),
            }),
          }),
        });

        try {
          schema.parse({
            'company': {
              'name': 123,
              'address': {
                'street': 456,
                'city': 789,
                'zipCode': 'invalid',
              },
            }
          });
          fail('Should have thrown');
        } catch (e) {
          final error = e as ZardError;

          // Tree format mostra estrutura aninhada
          final tree = treeifyError(error);
          expect(tree.properties, isNotNull);

          // Custom format mostra todos os erros
          final formatted = prettifyErrorBoxed(error);
          expect(formatted, contains('company'));
        }
      });
    });

    group('Integration with error maps', () {
      test('should preserve custom messages from error maps', () {
        final schema = ZMap({
          'email': ZString().email().errorMap((issue) => '📧 Email inválido!'),
          'phone': ZString().regex(RegExp(r'^\d{10,11}$')).errorMap((issue) {
            return '📱 Telefone deve ter 10 ou 11 dígitos';
          }),
        });

        try {
          schema.parse({
            'email': 'invalid',
            'phone': '123',
          });
          fail('Should have thrown');
        } catch (e) {
          final error = e as ZardError;

          // prettifyError built-in
          final pretty = prettifyError(error);
          expect(pretty, contains('📧 Email inválido!'));
          expect(pretty, contains('📱 Telefone deve ter 10 ou 11 dígitos'));

          // Custom formatter preserves messages
          final custom = prettifyErrorWithEmoji(error);
          expect(custom, contains('📧 Email inválido!'));

          // JSON format preserves messages
          final json = prettifyErrorJson(error);
          expect(json['errors'][0]['message'], contains('Email inválido'));
        }
      });
    });

    group('Practical examples', () {
      test('form validation with user-friendly messages', () {
        final loginSchema = ZMap({
          'email': ZString().email().errorMap((issue) {
            if (issue.type == 'email_error') {
              return 'Por favor, insira um email válido (ex: usuario@email.com)';
            }
            if (issue.type == 'type_error') {
              return 'Email é obrigatório';
            }
            return null;
          }),
          'password': ZString().min(6).errorMap((issue) {
            if (issue.type == 'min_error') {
              return 'Senha deve ter pelo menos 6 caracteres para sua segurança';
            }
            return null;
          }),
        });

        final result = loginSchema.safeParse({
          'email': 'invalid-email',
          'password': '123',
        });

        if (!result.success) {
          final flattened = flattenError(result.error!);

          expect(flattened.fieldErrors['email']!.first, contains('Por favor, insira um email válido'));
          expect(flattened.fieldErrors['password']!.first, contains('pelo menos 6 caracteres'));
        }
      });

      test('API error response format', () {
        final schema = ZMap({
          'title': ZString().min(5),
          'content': ZString().min(10),
          'published': ZBool(),
        });

        final result = schema.safeParse({
          'title': 'Hi',
          'content': 'Short',
          'published': 'yes',
        });

        if (!result.success) {
          final apiResponse = prettifyErrorJson(result.error!);

          // Verificações para API
          expect(apiResponse['status'], equals('error'));
          expect(apiResponse['timestamp'], isA<String>());
          expect(apiResponse['errors'], isA<List>());
          expect(apiResponse['count'], equals(result.error!.issues.length));

          // Cada erro tem os campos necessários
          for (final err in apiResponse['errors']) {
            expect(err['message'], isNotNull);
            expect(err['code'], isNotNull);
          }
        }
      });
    });
  });
}
