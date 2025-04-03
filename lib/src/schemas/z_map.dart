import 'package:zard/src/schemas/schemas.dart';

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
      addError(
        ZardError(
          message: 'Expected a Map',
          type: 'type_error',
          value: value,
        ),
      );
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    Map<String, dynamic> result = {};

    schemas.forEach((key, schema) {
      dynamic fieldValue = value[key];
      try {
        // Se o valor do campo for null e o schema permitir nulo (optional ou nullable)
        if (fieldValue == null) {
          if (schema.isOptional || schema.isNullable) {
            result[key] = null;
          } else {
            schema.addError(
              ZardError(
                message: 'Field "$key" is required',
                type: 'required_error',
                value: fieldValue,
              ),
            );
          }
        } else {
          // Valida o campo utilizando o schema específico
          result[key] = schema.parse(fieldValue);
        }
      } catch (e) {
        // Se ocorrer exceção na validação/parsing, os erros já estarão acumulados no schema
      }
      // Coleta os erros de cada sub-schema
      errors.addAll(schema.getErrors());
    });

    if (_strict) {
      for (var key in value.keys) {
        if (!schemas.containsKey(key)) {
          addError(ZardError(
            message: 'Unexpected key "$key" found in object',
            type: 'strict_error',
            value: value[key],
          ));
        }
      }
    }

    if (_refineValidator != null) {
      if (!_refineValidator!(result)) {
        addError(ZardError(
          message: _refineMessage ?? "Refinement failed",
          type: "refine_error",
          value: result,
        ));
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    return result;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    try {
      final parsed = parse(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {
        'success': false,
        'errors': errors.map((e) => e.toString()).toList()
      };
    }
  }

  @override
  Future<Map<String, dynamic>?> parseAsync(dynamic value) async {
    clearErrors();
    try {
      // Se o valor for um Future, aguarda a resolução
      final resolvedValue = value is Future ? await value : value;

      if (resolvedValue is! Map) {
        addError(
          ZardError(
            message: 'Expected a Map',
            type: 'type_error',
            value: resolvedValue,
          ),
        );
        throw Exception(
            'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
      }

      Map<String, dynamic> result = {};

      for (var key in schemas.keys) {
        final schema = schemas[key]!;
        dynamic fieldValue = resolvedValue[key];
        try {
          if (fieldValue == null) {
            if (schema.isOptional || schema.isNullable) {
              result[key] = null;
            } else {
              schema.addError(
                ZardError(
                  message: 'Field "$key" is required',
                  type: 'required_error',
                  value: fieldValue,
                ),
              );
            }
          } else {
            // Se o schema do campo possuir parseAsync, utiliza-o
            if (schema is ZMap ||
                schema is ZList ||
                schema is ZString ||
                schema is ZInt ||
                schema is ZDouble ||
                schema is ZBool ||
                schema is ZDate) {
              try {
                result[key] = await schema.parseAsync(fieldValue);
              } catch (e) {
                // erros já são acumulados no schema
              }
            } else {
              result[key] = schema.parse(fieldValue);
            }
          }
        } catch (e) {
          // erros já foram acumulados no schema
        }
        errors.addAll(schema.getErrors());
      }

      if (_strict) {
        for (var key in resolvedValue.keys) {
          if (!schemas.containsKey(key)) {
            addError(ZardError(
              message: 'Unexpected key "$key" found in object',
              type: 'strict_error',
              value: resolvedValue[key],
            ));
          }
        }
      }

      if (errors.isNotEmpty) {
        throw Exception(
            'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
      }

      return result;
    } catch (e) {
      return Future.error(Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}'));
    }
  }

  @override
  Future<Map<String, dynamic>> safeParseAsync(dynamic value) async {
    try {
      final parsed = await parseAsync(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {
        'success': false,
        'errors': errors.map((e) => e.toString()).toList()
      };
    }
  }

  /// Use .keyOf to create a ZodEnum schema from the keys of an object schema.
  /// Example:
  /// ```dart
  /// final schema = z.map({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// }).keyof();
  /// ```
  /// schema // ZodEnum<["name", "age", "email"]>
  ZEnum keyof() {
    return ZEnum(schemas.keys.toList());
  }

  /// Use .pick to create a new schema that only includes the specified keys.
  /// Example:
  /// ```dart
  /// final schema = z.map({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// });
  /// final pickedSchema = schema.pick(['name', 'age']); // ZMap<String, Schema>
  /// ```
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
  /// Example:
  /// ```dart
  /// final schema = z.map({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// });
  /// final omittedSchema = schema.omit(['email']); // ZMap<String, Schema>
  /// ```
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
    // ZMap({'name': z.string()})
    return 'ZMap(${schemas.toString()})';
  }
}
