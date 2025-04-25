import 'package:zard/src/schemas/schemas.dart';

import '../types/zard_issue.dart';
import '../types/zart_error.dart';

class ZMap extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;
  bool _strict = false;
  bool Function(Map<String, dynamic> value)? _refineValidator;
  String? _refineMessage;

  ZMap(this.schemas);

  ZMap strict() {
    _strict = true;
    return this;
  }

  @override
  ZMap refine(bool Function(Map<String, dynamic> value) predicate,
      {String? message}) {
    _refineValidator = predicate;
    _refineMessage = message;
    return this;
  }

  @override
  Map<String, dynamic>? parse(dynamic value) {
    clearErrors();

    if (value is! Map) {
      addError(ZardIssue(
        message: 'Expected a Map',
        type: 'type_error',
        value: value,
      ));
      throw ZardError(issues);
    }

    Map<String, dynamic> result = {};

    // Itera sobre as chaves definidas no schema
    schemas.forEach((key, schema) {
      if (!value.containsKey(key)) {
        // Campo omitido: se for opcional, não adicione ao resultado.
        if (!schema.isOptional) {
          addError(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
          ));
        }
      } else {
        dynamic fieldValue = value[key];
        try {
          if (fieldValue == null) {
            // A chave foi enviada com valor null
            if (schema.isNullable) {
              result[key] = null;
            } else {
              addError(ZardIssue(
                message: 'Field "$key" cannot be null',
                type: 'null_error',
                value: fieldValue,
              ));
            }
          } else {
            // Valida o campo utilizando o schema específico
            result[key] = schema.parse(fieldValue);
          }
        } catch (e) {
          if (e is ZardError) {
            // Propaga os erros específicos do sub-schema
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
  Map<String, dynamic> safeParse(dynamic value) {
    try {
      final parsed = parse(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      if (e is ZardError) {
        return {
          'success': false,
          'errors': e.issues.map((issue) => issue.toString()).toList(),
        };
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> parseAsync(dynamic value) async {
    clearErrors();
    try {
      final resolvedValue = value is Future ? await value : value;

      if (resolvedValue is! Map) {
        addError(ZardIssue(
          message: 'Expected a Map',
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
  Future<Map<String, dynamic>> safeParseAsync(dynamic value) async {
    try {
      final parsed = await parseAsync(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      if (e is ZardError) {
        return {
          'success': false,
          'errors': e.issues.map((issue) => issue.toString()).toList(),
        };
      }
      rethrow;
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
