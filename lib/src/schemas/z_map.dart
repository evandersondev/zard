import 'package:zard/src/schemas/schemas.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

abstract interface class ZMap extends Schema<Map<String, dynamic>> {
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
        path: path,
      ));
      throw ZardError(issues);
    }

    Map<String, dynamic> result = {};

    schemas.forEach((key, schema) {
      final fieldPath = path.isEmpty ? key : '$path.$key';

      if (!value.containsKey(key)) {
        // Campo não fornecido
        if (!schema.isOptional) {
          addError(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: fieldPath,
          ));
        } else {
          // Campo opcional - aplicar default
          try {
            result[key] = schema.parse(null, path: fieldPath);
          } catch (e) {
            if (e is ZardError) {
              issues.addAll(e.issues);
            } else if (e is! ZardError) {
              rethrow;
            }
          }
        }
      } else {
        dynamic fieldValue = value[key];
        try {
          // Se o valor é null, deixar o schema lidar com ele (seja nullable ou default)
          result[key] = schema.parse(fieldValue, path: fieldPath);
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
            path: path.isEmpty ? key : '$path.$key',
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
          path: path,
        ));
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> parseAsync(dynamic value,
      {String path = ''}) async {
    clearErrors();
    try {
      final resolvedValue = value is Future ? await value : value;

      if (resolvedValue is! Map) {
        addError(ZardIssue(
          message: message ?? 'Expected a Map',
          type: 'type_error',
          value: resolvedValue,
          path: path,
        ));
        throw ZardError(issues);
      }

      Map<String, dynamic> result = {};

      for (var key in schemas.keys) {
        final schema = schemas[key]!;
        final fieldPath = path.isEmpty ? key : '$path.$key';

        if (!resolvedValue.containsKey(key)) {
          // Campo não fornecido
          if (!schema.isOptional) {
            addError(ZardIssue(
              message: 'Field "$key" is required',
              type: 'required_error',
              value: null,
              path: fieldPath,
            ));
          } else {
            // Campo opcional - aplicar default
            try {
              result[key] = await schema.parseAsync(null, path: fieldPath);
            } catch (e) {
              if (e is ZardError) {
                issues.addAll(e.issues);
              } else if (e is! ZardError) {
                rethrow;
              }
            }
          }
        } else {
          dynamic fieldValue = resolvedValue[key];
          try {
            // Se o valor é null, deixar o schema lidar com ele (seja nullable ou default)
            result[key] = await schema.parseAsync(fieldValue, path: fieldPath);
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
              path: path.isEmpty ? key : '$path.$key',
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
    return ZEnumImpl(schemas.keys.toList());
  }

  /// Use .pick to create a new schema that only includes the specified keys.
  ZMap pick(List<String> keys) {
    final newSchemas = <String, Schema>{};
    for (final key in keys) {
      if (schemas.containsKey(key)) {
        newSchemas[key] = schemas[key]!;
      }
    }
    return ZMapImpl(newSchemas);
  }

  /// Use .omit to create a new schema that excludes the specified keys.
  ZMap omit(List<String> keys) {
    final newSchemas = <String, Schema>{};
    for (final key in schemas.keys) {
      if (!keys.contains(key)) {
        newSchemas[key] = schemas[key]!;
      }
    }
    return ZMapImpl(newSchemas);
  }

  @override
  String toString() {
    return 'ZMap(${schemas.toString()})';
  }
}

class ZMapImpl extends ZMap {
  ZMapImpl(super.schemas, {super.message});
}
