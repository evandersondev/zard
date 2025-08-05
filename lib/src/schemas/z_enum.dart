import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import '../types/zard_result.dart';

import 'schema.dart';

class ZEnum extends Schema<String> {
  final List<String> _allowedValues;
  final String? message;

  ZEnum(this._allowedValues, {this.message}) {
    addValidator((String? value) {
      if (value == null) {
        return ZardIssue(
          message: message ?? 'Expected a string',
          type: 'type_error',
          value: value,
        );
      }

      if (!_allowedValues.contains(value)) {
        return ZardIssue(
          message: message ?? 'Value must be one of $_allowedValues',
          type: 'enum_error',
          value: value,
        );
      }

      return null;
    });
  }

  /// Extract value from enum transform.
  /// Example:
  /// ```dart
  /// final value = z.enum(['a', 'b', 'c']).extract(['a', 'b']);
  /// print(value); // Prints: ['a', 'b']
  /// ```
  ZEnum extract(List<String> list) {
    final filteredValues =
        _allowedValues.where((e) => list.contains(e)).toList();
    return ZEnum(filteredValues, message: message);
  }

  /// Exclude value from enum transform.
  /// Example:
  /// ```dart
  /// final value = z.enum(['a', 'b', 'c']).exclude(['a', 'b']);
  /// print(value); // Prints: ['c']
  /// ```
  ZEnum exclude(List<String> list) {
    final filteredValues =
        _allowedValues.where((e) => !list.contains(e)).toList();
    return ZEnum(filteredValues, message: message);
  }

  @override
  String parse(dynamic value, {String path = ''}) {
    clearErrors();

    // Verifica se o valor é uma string
    if (value is! String) {
      addError(ZardIssue(
        message: 'Expected a string',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    // Verifica se o valor está nos valores permitidos
    if (!_allowedValues.contains(value)) {
      addError(ZardIssue(
        message: 'Value must be one of $_allowedValues',
        type: 'enum_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    // Validações adicionais
    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(ZardIssue(
          message: error.message,
          type: error.type,
          value: value,
          path: path.isEmpty ? null : path,
        ));
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return value;
  }

  @override
  Future<String> parseAsync(dynamic value, {String path = ''}) async {
    clearErrors();
    try {
      final resolvedValue = value is Future ? await value : value;
      return parse(resolvedValue, path: path);
    } catch (e) {
      return Future.error(ZardError(issues));
    }
  }

  @override
  ZardResult safeParse(dynamic value, {String path = ''}) {
    try {
      final parsed = parse(value, path: path);
      return ZardResult(
        success: true,
        data: parsed,
      );
    } catch (e) {
      return ZardResult(
        success: false,
        error: ZardError(issues),
      );
    }
  }

  @override
  Future<ZardResult> safeParseAsync(dynamic value, {String path = ''}) async {
    try {
      final parsed = await parseAsync(value, path: path);
      return ZardResult(
        success: true,
        data: parsed,
      );
    } catch (e) {
      return ZardResult(
        success: false,
        error: ZardError(issues),
      );
    }
  }

  @override
  String toString() {
    return 'ZEnum($_allowedValues)';
  }
}
