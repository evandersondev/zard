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
  Map<String, dynamic>? parseInto(
      dynamic value, String path, List<ZardIssue> sink) {
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
    if (value is! Map) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a Map',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    final result = <String, dynamic>{};
    final beforeOuter = sink.length;

    for (final entry in schemas.entries) {
      final key = entry.key;
      final schema = entry.value;
      final fieldPath = joinPath(path, key);

      final fieldValue = value[key];
      final hasKey = fieldValue != null || value.containsKey(key);

      final before = sink.length;
      final parsed = schema.parseInto(fieldValue, fieldPath, sink);

      if (sink.length == before) {
        if (parsed != null || hasKey) {
          result[key] = parsed;
        }
      } else if (!hasKey && schema.isOptional) {
        sink.length = before;
      }
    }

    if (_strict) {
      for (final key in value.keys) {
        if (!schemas.containsKey(key)) {
          sink.add(ZardIssue(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: value[key],
            path: joinPath(path, key.toString()),
          ));
        }
      }
    }

    if (_refineValidator != null && !_refineValidator!(result)) {
      sink.add(ZardIssue(
        message: _refineMessage ?? 'Refinement failed',
        type: 'refine_error',
        value: result,
        path: pathOrNull,
      ));
    }

    return sink.length == beforeOuter ? result : null;
  }

  @override
  Map<String, dynamic> parse(dynamic value, {String path = ''}) {
    final pathOrNull = path.isEmpty ? null : path;

    if (value == null) {
      throw ZardError([
        ZardIssue(
          message: message ?? 'Value is required and cannot be null',
          type: 'required_error',
          value: value,
          path: pathOrNull,
        )
      ]);
    }

    if (value is! Map) {
      throw ZardError([
        ZardIssue(
          message: message ?? 'Expected a Map',
          type: 'type_error',
          value: value,
          path: pathOrNull,
        )
      ]);
    }

    final result = <String, dynamic>{};
    // Single sink reused across all fields — `parseInto` writes errors here.
    // No per-field try/catch overhead.
    final localIssues = <ZardIssue>[];

    for (final entry in schemas.entries) {
      final key = entry.key;
      final schema = entry.value;
      final fieldPath = joinPath(path, key);

      // Single lookup: read once, then disambiguate "missing" vs "present-but-null".
      final fieldValue = value[key];
      final hasKey = fieldValue != null || value.containsKey(key);

      final before = localIssues.length;
      final parsed = schema.parseInto(fieldValue, fieldPath, localIssues);

      if (localIssues.length == before) {
        // Success — include the field unless it was both missing AND null.
        if (parsed != null || hasKey) {
          result[key] = parsed;
        }
      } else if (!hasKey && schema.isOptional) {
        // Missing optional field: rollback any issues the schema reported.
        localIssues.length = before;
      }
    }

    if (_strict) {
      for (final key in value.keys) {
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
        path: pathOrNull,
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
            final defaultVal = await schema.parseAsync(null, path: fieldPath);
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
            result[key] = await schema.parseAsync(fieldValue, path: fieldPath);
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
