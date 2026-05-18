import 'package:zard/src/schemas/schemas.dart';
import 'package:zard/src/types/parse_context.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

abstract interface class ZInterface extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;
  bool _strict = false;
  bool Function(Map<String, dynamic> value)? _refineValidator;
  String? _refineMessage;
  final String? message;

  ZInterface(Map<String, Schema> rawSchemas, {this.message})
      : schemas = _processRawSchemas(rawSchemas);

  // Keys ending with '?' are treated as optional.
  static Map<String, Schema> _processRawSchemas(
      Map<String, Schema> rawSchemas) {
    final Map<String, Schema> processed = {};
    rawSchemas.forEach((key, schema) {
      if (key.endsWith('?')) {
        final newKey = key.substring(0, key.length - 1);
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
    List<ZardIssue> localIssues;
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

    final Map<String, dynamic> result = {};
    localIssues = <ZardIssue>[];

    for (final entry in schemas.entries) {
      final key = entry.key;
      final schema = entry.value;
      final fieldPath = joinPath(path, key);

      final fieldValue = value[key];
      final hasKey = fieldValue != null || value.containsKey(key);

      if (!hasKey) {
        if (!schema.isOptional) {
          localIssues.add(ZardIssue(
            message: 'Field "$key" is required',
            type: 'required_error',
            value: null,
            path: fieldPath,
          ));
        }
      } else if (fieldValue == null) {
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
        final before = localIssues.length;
        final parsed = schema.parseInto(fieldValue, fieldPath, localIssues);
        if (localIssues.length == before) {
          result[key] = parsed;
        }
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
      ));
    }

    if (localIssues.isNotEmpty) {
      throw ZardError(localIssues);
    }

    return result;
  }

  @override
  String toString() => 'ZInterface(${schemas.toString()})';
}

class ZInterfaceImpl extends ZInterface {
  ZInterfaceImpl(super.schemas, {super.message});
}
