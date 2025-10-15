import 'package:zard/src/schemas/schemas.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

abstract interface class ZInterface extends Schema<Map<String, dynamic>> {
  // Map with effective keys (without "?" suffix) and their corresponding schemas.
  final Map<String, Schema> schemas;
  bool _strict = false;
  bool Function(Map<String, dynamic> value)? _refineValidator;
  String? _refineMessage;
  final String? message;

  ZInterface(Map<String, Schema> rawSchemas, {this.message})
      : schemas = _processRawSchemas(rawSchemas);

  // Processes the raw schema keys.
  // Keys ending with '?' are treated as optional.
  static Map<String, Schema> _processRawSchemas(
      Map<String, Schema> rawSchemas) {
    final Map<String, Schema> processed = {};
    rawSchemas.forEach((key, schema) {
      if (key.endsWith('?')) {
        // Remove the trailing '?' for the effective key
        final newKey = key.substring(0, key.length - 1);
        // Mark the schema as optional regardless
        processed[newKey] = schema.optional();
      } else {
        processed[key] = schema;
      }
    });
    return processed;
  }

  ZInterface strict() {
    _strict = true;
    return this;
  }

  @override
  ZInterface refine(bool Function(Map<String, dynamic> value) predicate,
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
        path: path,
      ));
      throw ZardError(issues);
    }

    Map<String, dynamic> result = {};

    schemas.forEach((key, schema) {
      if (!value.containsKey(key)) {
        // If the field is missing and the schema is not optional, add error.
        if (!schema.isOptional) {
          addError(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: path,
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
                path: path,
              ));
            }
          } else {
            result[key] = schema.parse(fieldValue);
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
      // Check for extra keys not defined in the interface.
      for (var key in value.keys) {
        if (!schemas.containsKey(key)) {
          addError(ZardIssue(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: value[key],
            path: path,
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
        ));
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> parseAsync(dynamic value, {String? path}) async {
    clearErrors();
    try {
      final resolvedValue = value is Future ? await value : value;

      if (resolvedValue is! Map) {
        addError(ZardIssue(
          message: message ?? 'Expected a Map',
          type: 'type_error',
          value: resolvedValue,
        ));
        throw ZardError(issues);
      }

      Map<String, dynamic> result = {};

      for (var key in schemas.keys) {
        final schema = schemas[key]!;
        if (!resolvedValue.containsKey(key)) {
          if (!schema.isOptional) {
            addError(ZardIssue(
              message: 'Field "$key" is required',
              type: 'required_error',
              value: null,
              path: path,
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
                  path: path,
                ));
              }
            } else {
              result[key] = await schema.parseAsync(fieldValue);
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
              path: path,
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

  @override
  String toString() {
    return 'ZInterface(${schemas.toString()})';
  }
}

class ZInterfaceImpl extends ZInterface {
  ZInterfaceImpl(super.schemas, {super.message});
}
