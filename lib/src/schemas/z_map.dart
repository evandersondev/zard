import 'package:zard/src/schemas/schemas.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

class ZMap extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;
  bool _strict = false;
  bool Function(Map<String, dynamic> value)? _refineValidator;
  String? _refineMessage;
  final String? message;

  ZMap(this.schemas, {this.message});

  ZMap strict() {
    _strict = true;
    return this;
  }

  @override
  ZMap refine(bool Function(Map<String, dynamic> value) predicate,
      {String? message, String? path}) {
    _refineValidator = predicate;
    _refineMessage = message;
    return this;
  }

  @override
  Map<String, dynamic> parse(dynamic value, {String path = ''}) {
    clearErrors();

    if (value is! Map) {
      addError(ZardIssue(
        message: message ?? 'Expected a Map',
        type: 'type_error',
        value: value,
        path: path, // Include the current path
      ));
      throw ZardError(issues);
    }

    Map<String, dynamic> result = {};

    schemas.forEach((key, schema) {
      final fieldPath = path.isEmpty ? key : '$path.$key'; // Track the path

      if (!value.containsKey(key)) {
        if (!schema.isOptional) {
          addError(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: fieldPath,
          ));
        }
      } else {
        dynamic fieldValue = value[key];
        try {
          if (fieldValue == null) {
            if (schema.isNullable) {
              result[key] = null;
            } else {
              addError(ZardIssue(
                  message: 'Field "$key" cannot be null',
                  type: 'null_error',
                  value: fieldValue,
                  path: fieldPath));
            }
          } else {
            result[key] = schema.parse(fieldValue, path: fieldPath);
          }
        } catch (e) {
          if (e is ZardError) {
            issues.addAll(e.issues);
          } else {
            rethrow;
          }
        }
      }
    });

    if (_strict) {
      for (var key in value.keys) {
        if (!schemas.containsKey(key)) {
          addError(ZardIssue(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: value[key],
            path: path.isEmpty ? key : '$path.$key', // Include the path
          ));
        }
      }
    }

    if (_refineValidator != null) {
      if (!_refineValidator!(result)) {
        addError(ZardIssue(
          message: _refineMessage ?? "Refinement failed",
          type: "refine_error",
          value: result,
          path: path, // Apply refinement path
        ));
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>?> parseAsync(dynamic value,
      {String path = ''}) async {
    clearErrors();
    try {
      final resolvedValue = value is Future ? await value : value;

      if (resolvedValue is! Map) {
        addError(ZardIssue(
          message: message ?? 'Expected a Map',
          type: 'type_error',
          value: resolvedValue,
          path: path, // Include the current path
        ));
        throw ZardError(issues);
      }

      Map<String, dynamic> result = {};

      for (var key in schemas.keys) {
        final schema = schemas[key]!;
        final fieldPath = path.isEmpty ? key : '$path.$key'; // Track the path

        if (!resolvedValue.containsKey(key)) {
          if (!schema.isOptional) {
            addError(ZardIssue(
              message: 'Field "$key" is required',
              type: 'required_error',
              value: null,
              path: fieldPath,
            ));
          }
        } else {
          dynamic fieldValue = resolvedValue[key];
          try {
            if (fieldValue == null) {
              if (schema.isNullable) {
                result[key] = null;
              } else {
                addError(ZardIssue(
                    message: 'Field "$key" cannot be null',
                    type: 'null_error',
                    value: fieldValue,
                    path: fieldPath));
              }
            } else {
              result[key] =
                  await schema.parseAsync(fieldValue, path: fieldPath);
            }
          } catch (e) {
            if (e is ZardError) {
              issues.addAll(e.issues);
            } else {
              rethrow;
            }
          }
        }
      }

      if (_strict) {
        for (var key in resolvedValue.keys) {
          if (!schemas.containsKey(key)) {
            addError(ZardIssue(
              message: 'Unexpected key "$key" found in object',
              type: 'strict_error',
              value: resolvedValue[key],
              path: path.isEmpty ? key : '$path.$key', // Include the path
            ));
          }
        }
      }

      if (issues.isNotEmpty) {
        throw ZardError(issues);
      }

      return result;
    } catch (e) {
      return Future.error(ZardError(issues));
    }
  }

  /// Use .keyOf to create a ZodEnum schema from the keys of an object schema.
  ZEnum keyof() {
    return ZEnum(schemas.keys.toList());
  }

  /// Use .pick to create a new schema that only includes the specified keys.
  ZMap pick(List<String> keys) {
    final newSchemas = <String, Schema>{};
    for (final key in keys) {
      if (schemas.containsKey(key)) {
        newSchemas[key] = schemas[key]!;
      }
    }
    return ZMap(newSchemas);
  }

  /// Use .omit to create a new schema that excludes the specified keys.
  ZMap omit(List<String> keys) {
    final newSchemas = <String, Schema>{};
    for (final key in schemas.keys) {
      if (!keys.contains(key)) {
        newSchemas[key] = schemas[key]!;
      }
    }
    return ZMap(newSchemas);
  }

  @override
  String toString() {
    return 'ZMap(${schemas.toString()})';
  }
}
