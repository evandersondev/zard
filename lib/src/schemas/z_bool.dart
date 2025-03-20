import '../types/zart_error.dart';
import 'schema.dart';

class ZBool extends Schema<bool> {
  ZBool({String? message}) {
    addValidator((value) {
      if (value != true && value != false) {
        return ZardError(
          message: message ?? 'Expected a boolean value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  @override
  bool parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! bool) {
      addError(
        ZardError(
          message: 'Expected a boolean value',
          type: 'type_error',
          value: value,
        ),
      );
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(error);
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    var transformedValue = value;
    for (final transform in getTransforms()) {
      transformedValue = transform(transformedValue);
    }

    return transformedValue;
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
}
