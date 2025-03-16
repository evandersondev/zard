import '../types/zart_error.dart';
import 'schema.dart';

class ZMap extends Schema<Map<String, dynamic>> {
  final Map<String, Schema> schemas;

  ZMap(this.schemas);

  @override
  Map<String, dynamic>? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! Map<String, dynamic>) {
      addError(
        ZardError(message: 'Expected a map', type: 'type_error', value: value),
      );
      return null;
    }

    final result = <String, dynamic>{};
    for (final key in schemas.keys) {
      final schema = schemas[key]!;
      if (value.containsKey(key)) {
        final parsedValue = schema.parse(value[key]);
        if (parsedValue == null && schema.getErrors().isNotEmpty) {
          errors.addAll(schema.getErrors());
        } else {
          result[key] = parsedValue;
        }
      } else if (!schema.isOptional) {
        addError(
          ZardError(
            message: 'Missing key: $key',
            type: 'missing_key',
            value: null,
          ),
        );
      } else {
        result[key] = null;
      }
    }

    if (errors.isNotEmpty) {
      return null;
    }

    return result;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    final parsed = parse(value);
    if (parsed == null) {
      return {'success': false, 'errors': getErrors()};
    }
    return {'success': true, 'data': parsed};
  }
}
