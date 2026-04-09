import 'package:zard/src/schemas/schemas.dart';
import 'package:zard/src/types/parse_context.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

abstract interface class ZMap extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;
  bool _strict = false;
  bool Function(Map<String, dynamic> value)? _refineValidator;
  String? _refineMessage;
  final String? message;

  ZMap(this.schemas, {this.message});

  /// Returns a map of field names to their expected Dart types.
  Map<String, Type> get shape {
    return schemas.map((key, schema) {
      Type schemaType = String;
      if (schema is ZInt) {
        schemaType = int;
      } else if (schema is ZDouble) {
        schemaType = double;
      } else if (schema is ZBool) {
        schemaType = bool;
      } else if (schema is ZString) {
        schemaType = String;
      } else if (schema is ZDate) {
        schemaType = DateTime;
      } else if (schema is ZList) {
        schemaType = List;
      } else if (schema is ZMap) {
        schemaType = Map;
      }
      return MapEntry(key, schemaType);
    });
  }

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

  // -----------------------------------------------------------------------
  // Zod-parity object methods
  // -----------------------------------------------------------------------

  /// Returns a new schema where all (or the specified) fields are optional.
  ZMap partial({List<String>? keys}) {
    final newSchemas = schemas.map((k, s) {
      if (keys == null || keys.contains(k)) {
        return MapEntry(k, s.optional());
      }
      return MapEntry(k, s);
    });
    return ZMapImpl(newSchemas, message: message);
  }

  /// Returns a new schema where all (or the specified) fields are required.
  ZMap required({List<String>? keys}) {
    final newSchemas = schemas.map((k, s) {
      if (keys == null || keys.contains(k)) {
        return MapEntry(k, s.markRequired());
      }
      return MapEntry(k, s);
    });
    return ZMapImpl(newSchemas, message: message);
  }

  /// Merges another [ZMap]'s fields into this schema.
  /// Fields from [other] win on key conflicts.
  ZMap merge(ZMap other) {
    return ZMapImpl({...schemas, ...other.schemas}, message: message);
  }

  /// Adds [extra] fields to the schema.
  ZMap extend(Map<String, Schema> extra) {
    return ZMapImpl({...schemas, ...extra}, message: message);
  }

  // -----------------------------------------------------------------------
  // Parsing
  // -----------------------------------------------------------------------

  @override
  Map<String, dynamic> parse(dynamic value, {String path = ''}) {
    // Use a LOCAL issues list so that recursive schema invocations (e.g. via
    // lazy circular references) cannot corrupt this call's error state by
    // replacing the shared _ctx via clearErrors().
    final localIssues = <ZardIssue>[];

    if (value == null) {
      localIssues.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    if (value is! Map) {
      localIssues.add(ZardIssue(
        message: message ?? 'Expected a Map',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    final Map<String, dynamic> result = {};

    schemas.forEach((key, schema) {
      final fieldPath = joinPath(path, key);

      if (!value.containsKey(key)) {
        // Field is absent.
        if (!schema.isOptional) {
          localIssues.add(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: fieldPath,
          ));
        } else {
          // Optional field — attempt to get a default value if one exists.
          try {
            final defaultVal = schema.parse(null, path: fieldPath);
            if (defaultVal != null) result[key] = defaultVal;
          } on ZardError {
            // No default; field simply absent from result.
          }
        }
      } else {
        final fieldValue = value[key];

        if (fieldValue == null) {
          // Field is present but null.
          if (schema.isNullable || schema.isOptional) {
            result[key] = null;
          } else {
            localIssues.add(ZardIssue(
              message: 'Field "$key" cannot be null',
              type: 'null_error',
              value: null,
              path: fieldPath,
            ));
          }
        } else {
          try {
            result[key] = schema.parse(fieldValue, path: fieldPath);
          } on ZardError catch (e) {
            localIssues.addAll(e.issues);
          }
        }
      }
    });

    if (_strict) {
      for (var key in value.keys) {
        if (!schemas.containsKey(key)) {
          localIssues.add(ZardIssue(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: value[key],
            path: joinPath(path, key.toString()),
          ));
        }
      }
    }

    if (_refineValidator != null && !_refineValidator!(result)) {
      localIssues.add(ZardIssue(
        message: _refineMessage ?? 'Refinement failed',
        type: 'refine_error',
        value: result,
        path: path.isEmpty ? null : path,
      ));
    }

    if (localIssues.isNotEmpty) {
      throw ZardError(localIssues);
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> parseAsync(dynamic value,
      {String path = ''}) async {
    final localIssues = <ZardIssue>[];

    if (value == null) {
      localIssues.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    final resolvedValue = value is Future ? await value : value;

    if (resolvedValue is! Map) {
      localIssues.add(ZardIssue(
        message: message ?? 'Expected a Map',
        type: 'type_error',
        value: resolvedValue,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    final Map<String, dynamic> result = {};

    for (final key in schemas.keys) {
      final schema = schemas[key]!;
      final fieldPath = joinPath(path, key);

      if (!resolvedValue.containsKey(key)) {
        if (!schema.isOptional) {
          localIssues.add(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: fieldPath,
          ));
        } else {
          try {
            final defaultVal =
                await schema.parseAsync(null, path: fieldPath);
            if (defaultVal != null) result[key] = defaultVal;
          } on ZardError {
            // No default; field simply absent.
          }
        }
      } else {
        final fieldValue = resolvedValue[key];

        if (fieldValue == null) {
          if (schema.isNullable || schema.isOptional) {
            result[key] = null;
          } else {
            localIssues.add(ZardIssue(
              message: 'Field "$key" cannot be null',
              type: 'null_error',
              value: null,
              path: fieldPath,
            ));
          }
        } else {
          try {
            result[key] =
                await schema.parseAsync(fieldValue, path: fieldPath);
          } on ZardError catch (e) {
            localIssues.addAll(e.issues);
          }
        }
      }
    }

    if (_strict) {
      for (var key in resolvedValue.keys) {
        if (!schemas.containsKey(key)) {
          localIssues.add(ZardIssue(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: resolvedValue[key],
            path: joinPath(path, key.toString()),
          ));
        }
      }
    }

    if (_refineValidator != null && !_refineValidator!(result)) {
      localIssues.add(ZardIssue(
        message: _refineMessage ?? 'Refinement failed',
        type: 'refine_error',
        value: result,
        path: path.isEmpty ? null : path,
      ));
    }

    if (localIssues.isNotEmpty) {
      throw ZardError(localIssues);
    }

    return result;
  }

  ZEnum keyof() {
    return ZEnumImpl(schemas.keys.toList());
  }

  ZMap pick(List<String> keys) {
    final newSchemas = <String, Schema>{};
    for (final key in keys) {
      if (schemas.containsKey(key)) {
        newSchemas[key] = schemas[key]!;
      }
    }
    return ZMapImpl(newSchemas);
  }

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
  String toString() => 'ZMap(${schemas.toString()})';
}

class ZMapImpl extends ZMap {
  ZMapImpl(super.schemas, {super.message});
}
