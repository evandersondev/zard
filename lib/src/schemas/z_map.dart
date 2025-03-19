import 'package:zard/src/schemas/schemas.dart';

import '../types/zart_error.dart';

class ZMap extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;

  ZMap(this.schemas);

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

    if (errors.isNotEmpty) {
      return null;
    }

    return result;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    final parsed = parse(value);
    return {'success': true, 'data': parsed};
  }

  /// Use .keyof to create a ZodEnum schema from the keys of an object schema.
  /// Example:
  /// ```dart
  /// final schema = z.object({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// }).keyof();
  /// ```
  /// schema // ZodEnum<["name", "age"]>
  ZEnum keyof() {
    return ZEnum(schemas.keys.toList());
  }

  /// Use .pick to create a new schema that only includes the specified maps.
  /// Example:
  /// ```dart
  /// final schema = z.object({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// });
  /// final schema = schema.pick(['name']); // ZMap<String, Schema>
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

  /// Use .omit to create a new schema that excludes the specified maps.
  /// Example:
  /// ```dart
  /// final schema = z.object({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'email': z.string().email(),
  /// });
  /// final schema = schema.omit(['name']); // ZMap<String, Schema>
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
