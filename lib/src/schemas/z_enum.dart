import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZEnum extends Schema<String> {
  final List<String> _allowedValues;
  final String? message;

  ZEnum(this._allowedValues, {this.message});
  // No constructor validator: parse() below does the null + type + allowed
  // checks directly. Adding the same logic here would just allocate a closure.

  /// The allowed values of this enum.
  ///
  /// Exposed for introspection (e.g. generating OpenAPI / JSON Schema).
  List<String> get values => List.unmodifiable(_allowedValues);

  /// Extract value from enum transform.
  /// Example:
  /// ```dart
  /// final value = z.enum(['a', 'b', 'c']).extract(['a', 'b']);
  /// print(value); // Prints: ['a', 'b']
  /// ```
  ZEnum extract(List<String> list) {
    final filteredValues =
        _allowedValues.where((e) => list.contains(e)).toList();
    return ZEnumImpl(filteredValues, message: message);
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
    return ZEnumImpl(filteredValues, message: message);
  }

  @override
  String? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final pathOrNull = path.isEmpty ? null : path;

    if (value == null) {
      sink.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    if (value is! String) {
      sink.add(ZardIssue(
        message: 'Expected a string',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    if (!_allowedValues.contains(value)) {
      sink.add(ZardIssue(
        message: 'Value must be one of $_allowedValues',
        type: 'enum_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    final beforeLen = sink.length;
    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](value);
      if (error != null) {
        if (pathOrNull == null && error.value == value) {
          sink.add(error);
        } else {
          sink.add(ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: pathOrNull,
          ));
        }
      }
    }
    if (sink.length != beforeLen) return null;

    return value;
  }

  @override
  String parse(dynamic value, {String path = ''}) {
    clearErrors();
    final pathOrNull = path.isEmpty ? null : path;
    final sink = issuesInternal;

    if (value == null) {
      sink.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(sink);
    }

    if (value is! String) {
      sink.add(ZardIssue(
        message: 'Expected a string',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(sink);
    }

    if (!_allowedValues.contains(value)) {
      sink.add(ZardIssue(
        message: 'Value must be one of $_allowedValues',
        type: 'enum_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(sink);
    }

    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](value);
      if (error != null) {
        if (pathOrNull == null && error.value == value) {
          sink.add(error);
        } else {
          sink.add(ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: pathOrNull,
          ));
        }
      }
    }

    if (sink.isNotEmpty) {
      throw ZardError(sink);
    }

    return value;
  }

  @override
  Future<String> parseAsync(dynamic value, {String path = ''}) async {
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue, path: path);
  }

  @override
  String toString() {
    return 'ZEnum($_allowedValues)';
  }
}

class ZEnumImpl extends ZEnum {
  ZEnumImpl(super._allowedValues, {super.message});
}
