import 'package:zard/zard.dart';

/// Exemplo de formatação customizada de erros

// 1. Formatar com emojis personalizados
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

// 2. Formatar em caixa bonita
String prettifyErrorBoxed(ZardError error) {
  final buffer = StringBuffer();
  buffer.writeln('╔═══════════════════════════════════════╗');
  buffer.writeln('║  ERROS DE VALIDAÇÃO                   ║');
  buffer.writeln('╚═══════════════════════════════════════╝\n');

  for (var i = 0; i < error.issues.length; i++) {
    final issue = error.issues[i];
    buffer.write('${i + 1}. ${issue.message}');

    if (issue.path != null && issue.path!.isNotEmpty) {
      buffer.write('\n   📍 Campo: ${issue.path}');
    }
    buffer.write('\n');
  }

  return buffer.toString();
}

// 3. Formatar como JSON para APIs
Map<String, dynamic> prettifyErrorJson(ZardError error) {
  return {
    'status': 'error',
    'timestamp': DateTime.now().toIso8601String(),
    'errors': error.issues
        .map((issue) => {
              'message': issue.message,
              'field': issue.path,
              'code': issue.type,
            })
        .toList(),
  };
}

void main() {
  print('=== EXEMPLO 1: Formatação com Emoji ===\n');

  final schema1 = ZMap({
    'username': ZString().min(3),
    'email': ZString().email(),
  });

  try {
    schema1.parse({
      'username': 'ab',
      'email': 'invalid',
    });
  } catch (e) {
    if (e is ZardError) {
      print(prettifyErrorWithEmoji(e, emoji: '⚠️'));
    }
  }

  print('\n\n=== EXEMPLO 2: Formatação em Caixa ===\n');

  final schema2 = ZMap({
    'age': ZInt().min(18),
    'password': ZString().min(8),
  });

  try {
    schema2.parse({
      'age': 15,
      'password': '123',
    });
  } catch (e) {
    if (e is ZardError) {
      print(prettifyErrorBoxed(e));
    }
  }

  print('\n=== EXEMPLO 3: Formatação JSON (API) ===\n');

  final schema3 = ZMap({
    'title': ZString(),
    'published': ZBool(),
  });

  final result = schema3.safeParse({
    'title': 123,
    'published': 'yes',
  });

  if (!result.success) {
    final json = prettifyErrorJson(result.error!);
    print(json);
  }

  print('\n\n=== EXEMPLO 4: Error Maps com Mensagens Customizadas ===\n');

  final schema4 = ZMap({
    'email': ZString().email().errorMap((issue) {
      if (issue.type == 'email_error') {
        return '📧 Email inválido! Use o formato: usuario@dominio.com';
      }
      return null;
    }),
    'password': ZString().min(8).errorMap((issue) {
      if (issue.type == 'min_error') {
        return '🔒 Senha muito curta! Use no mínimo 8 caracteres';
      }
      return null;
    }),
  });

  try {
    schema4.parse({
      'email': 'invalid',
      'password': '123',
    });
  } catch (e) {
    if (e is ZardError) {
      // Usa o prettifyError built-in
      print('Built-in prettifyError:');
      print(prettifyError(e));

      print('\n\nCustom prettifyError:');
      print(prettifyErrorBoxed(e));
    }
  }

  print('\n\n=== EXEMPLO 5: Flatten para Formulários ===\n');

  final schema5 = ZMap({
    'user': ZMap({
      'name': ZString(),
      'email': ZString().email(),
    }),
    'settings': ZMap({
      'notifications': ZBool(),
    }),
  });

  final result5 = schema5.safeParse({
    'user': {
      'name': 123,
      'email': 'invalid',
    },
    'settings': {
      'notifications': 'yes',
    },
  });

  if (!result5.success) {
    final flattened = flattenError(result5.error!);

    print('Form errors: ${flattened.formErrors}');
    print('Field errors:');
    flattened.fieldErrors.forEach((field, errors) {
      print('  $field: $errors');
    });
  }

  print('\n\n=== EXEMPLO 6: Nullish com Error Maps ===\n');

  final schema6 = ZMap({
    'name': ZString(),
    'nickname': ZString().nullish().errorMap((issue) => 'Apelido inválido'),
    'website': ZString().url().nullish(),
  });

  // Todos esses são válidos:
  print('✅ Campo omitido:');
  final r1 = schema6.safeParse({'name': 'John'});
  print('  Success: ${r1.success}');

  print('\n✅ Campo null:');
  final r2 = schema6.safeParse({'name': 'John', 'nickname': null});
  print('  Success: ${r2.success}');

  print('\n✅ Campo com valor:');
  final r3 = schema6.safeParse({'name': 'John', 'nickname': 'Johnny'});
  print('  Success: ${r3.success}');
}
