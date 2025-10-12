import 'zard_error.dart';
import 'zard_issue.dart';

/// Estrutura de erro em árvore
class ZardErrorTree {
  final List<String> errors;
  final Map<String, ZardErrorTree>? properties;
  final List<ZardErrorTree?>? items;

  ZardErrorTree({
    this.errors = const [],
    this.properties,
    this.items,
  });

  @override
  String toString() {
    return 'ZardErrorTree(errors: $errors, properties: $properties, items: $items)';
  }
}

/// Estrutura de erro plana
class ZardFlattenedError {
  final List<String> formErrors;
  final Map<String, List<String>> fieldErrors;

  ZardFlattenedError({
    this.formErrors = const [],
    this.fieldErrors = const {},
  });

  @override
  String toString() {
    return 'ZardFlattenedError(formErrors: $formErrors, fieldErrors: $fieldErrors)';
  }
}

/// Converte um ZardError em uma estrutura de árvore aninhada
///
/// Exemplo:
/// ```dart
/// final tree = treeifyError(error);
/// tree.properties?['username']?.errors; // => ["Campo inválido"]
/// ```
ZardErrorTree treeifyError(ZardError error) {
  final Map<String, List<ZardIssue>> grouped = {};
  final List<ZardIssue> rootIssues = [];

  // Agrupa os issues por path
  for (final issue in error.issues) {
    if (issue.path == null || issue.path!.isEmpty) {
      rootIssues.add(issue);
    } else {
      final key = issue.path!;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(issue);
    }
  }

  // Cria a árvore
  final Map<String, ZardErrorTree> properties = {};
  final Map<int, ZardErrorTree> items = {};

  for (final entry in grouped.entries) {
    final path = entry.key;
    final issues = entry.value;

    // Divide o path em partes
    final parts = _parsePath(path);

    if (parts.isEmpty) continue;

    final firstPart = parts[0];

    if (firstPart.isIndex) {
      // É um índice de array
      final index = int.parse(firstPart.value);
      if (parts.length == 1) {
        items[index] = ZardErrorTree(
          errors: issues.map((i) => i.message).toList(),
        );
      } else {
        // Path mais profundo
        final subPath = _joinPath(parts.sublist(1));
        final subError = ZardError(issues
            .map((i) => ZardIssue(
                  message: i.message,
                  type: i.type,
                  value: i.value,
                  path: subPath,
                ))
            .toList());
        items[index] = treeifyError(subError);
      }
    } else {
      // É uma propriedade
      if (parts.length == 1) {
        properties[firstPart.value] = ZardErrorTree(
          errors: issues.map((i) => i.message).toList(),
        );
      } else {
        // Path mais profundo
        final subPath = _joinPath(parts.sublist(1));
        final subError = ZardError(issues
            .map((i) => ZardIssue(
                  message: i.message,
                  type: i.type,
                  value: i.value,
                  path: subPath,
                ))
            .toList());
        properties[firstPart.value] = treeifyError(subError);
      }
    }
  }

  return ZardErrorTree(
    errors: rootIssues.map((i) => i.message).toList(),
    properties: properties.isEmpty ? null : properties,
    items: items.isEmpty ? null : _convertItemsMapToList(items),
  );
}

/// Converte um ZardError em uma string legível
///
/// Exemplo:
/// ```dart
/// print(prettifyError(error));
/// // ✖ Campo obrigatório
/// //   → at username
/// // ✖ Deve ser um número
/// //   → at age
/// ```
String prettifyError(ZardError error) {
  final buffer = StringBuffer();

  for (var i = 0; i < error.issues.length; i++) {
    final issue = error.issues[i];
    buffer.write('✖ ${issue.message}');

    if (issue.path != null && issue.path!.isNotEmpty) {
      buffer.write('\n  → at ${issue.path}');
    }

    if (i < error.issues.length - 1) {
      buffer.write('\n');
    }
  }

  return buffer.toString();
}

/// Converte um ZardError em uma estrutura plana (apenas um nível)
///
/// Exemplo:
/// ```dart
/// final flattened = flattenError(error);
/// flattened.formErrors; // => ["Erro geral"]
/// flattened.fieldErrors['username']; // => ["Campo inválido"]
/// ```
ZardFlattenedError flattenError(ZardError error) {
  final List<String> formErrors = [];
  final Map<String, List<String>> fieldErrors = {};

  for (final issue in error.issues) {
    if (issue.path == null || issue.path!.isEmpty) {
      formErrors.add(issue.message);
    } else {
      // Pega apenas o primeiro segmento do path para achatar
      final firstSegment = _getFirstPathSegment(issue.path!);
      fieldErrors.putIfAbsent(firstSegment, () => []);
      fieldErrors[firstSegment]!.add(issue.message);
    }
  }

  return ZardFlattenedError(
    formErrors: formErrors,
    fieldErrors: fieldErrors,
  );
}

// Helper classes e funções
class _PathPart {
  final String value;
  final bool isIndex;

  _PathPart(this.value, this.isIndex);
}

List<_PathPart> _parsePath(String path) {
  final parts = <_PathPart>[];
  final segments = path.split('.');

  for (final segment in segments) {
    if (segment.isEmpty) continue;

    // Verifica se é um índice de array [n]
    final indexMatch = RegExp(r'\[(\d+)\]').firstMatch(segment);
    if (indexMatch != null) {
      final index = indexMatch.group(1)!;
      parts.add(_PathPart(index, true));
    } else {
      parts.add(_PathPart(segment, false));
    }
  }

  return parts;
}

String _joinPath(List<_PathPart> parts) {
  return parts.map((p) {
    if (p.isIndex) {
      return '[${p.value}]';
    }
    return p.value;
  }).join('.');
}

List<ZardErrorTree?> _convertItemsMapToList(Map<int, ZardErrorTree> items) {
  if (items.isEmpty) return [];

  final maxIndex = items.keys.reduce((a, b) => a > b ? a : b);
  final list = List<ZardErrorTree?>.filled(maxIndex + 1, null);

  items.forEach((index, tree) {
    list[index] = tree;
  });

  return list;
}

String _getFirstPathSegment(String path) {
  // Remove índices de array se houver
  final cleaned = path.split('[')[0];
  // Pega o primeiro segmento
  final parts = cleaned.split('.');
  return parts.first;
}
