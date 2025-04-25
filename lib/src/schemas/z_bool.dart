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
  bool parse(dynamic value) {
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

  @override
  Future<bool> parseAsync(dynamic value) async {
    clearErrors();
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue);
  }

  @override
  Future<Map<String, dynamic>> safeParseAsync(
    dynamic value,
  ) async {
    try {
      final parsed = await parseAsync(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      final errorMessages = errors.isNotEmpty
          ? errors.map((e) => e.toString()).toList()
          : [e.toString()];
      return {'success': false, 'errors': errorMessages};
    }
  }
}

class ZCoerceBoolean extends Schema<bool> {
  ZCoerceBoolean({String? message});

  @override
  bool parse(dynamic value) {
    clearErrors();
    try {
      // Considera false se o valor for: 0, '0', "", false ou null; caso contrário, true.
      if (value == 0 ||
          value == '0' ||
          value == '' ||
          value == false ||
          value == null) {
        return false;
      }
      return true;
    } catch (e) {
      addError(ZardError(
        message: 'Failed to coerce value to boolean',
        type: 'coerce_error',
        value: value,
      ));
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }
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
