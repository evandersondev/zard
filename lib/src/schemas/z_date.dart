import '../types/zart_error.dart';
import 'schemas.dart';

class ZDate extends Schema<DateTime> {
  final String? message;

  ZDate({this.message});

  /// Adds a validator that checks for a valid datetime format.
  ZDate datetime() {
    addValidator((dynamic value) {
      return _validate(value);
    });
    return this;
  }

  /// Performs validation on the provided value to ensure it represents a valid datetime.
  ZardError? _validate(dynamic value) {
    // If value is a DateTime instance, convert it to ISO8601 string for validation.
    String valueStr =
        value is DateTime ? value.toIso8601String() : value.toString();

    // Regex pattern supporting various date formats.
    final dateRegExp = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$|^(\d{1,2})/(\d{1,2})/(\d{2,4})$|^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)((?:[+-](\d{2}):(\d{2})|Z)?)$',
    );
    if (!dateRegExp.hasMatch(valueStr)) {
      return ZardError(
        message: message ?? 'Invalid datetime format',
        type: 'datetime',
        value: value,
      );
    }

    // Try to parse the date.
    final parsedDate = DateTime.tryParse(valueStr);
    if (parsedDate == null) {
      return ZardError(
        message: message ?? 'Invalid datetime format',
        type: 'datetime',
        value: value,
      );
    }

    // Additional validation: Check individual date components.
    final components = valueStr
        .split(RegExp(r'[-T:/\.Z+]'))
        .where((c) => c.isNotEmpty)
        .toList();
    if (components.length >= 3) {
      final year = int.tryParse(components[0]) ?? 0;
      final month = int.tryParse(components[1]) ?? 0;
      final day = int.tryParse(components[2]) ?? 0;

      if (year < 1 || month < 1 || month > 12 || day < 1 || day > 31) {
        return ZardError(
          message: message ?? 'Invalid datetime format',
          type: 'datetime',
          value: value,
        );
      }
    }

    return null;
  }

  @override
  DateTime? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value == null && isOptional) {
      return null;
    }

    final validationResult = _validate(value);
    if (validationResult != null) {
      addError(
        ZardError(
          message: validationResult.message,
          type: validationResult.type,
          value: value,
        ),
      );
      throw Exception(
          'Validation failed with errors: ${getErrors().map((e) => e.toString()).toList()}');
    }

    if (value is String) {
      try {
        final date = DateTime.parse(value);
        // Optionally, process transformations if any exist.
        DateTime transformedValue = date;
        for (final transform in getTransforms()) {
          transformedValue = transform(transformedValue);
        }
        return transformedValue;
      } catch (e) {
        addError(
          ZardError(
            message: message ?? 'Invalid date format',
            type: 'datetime',
            value: value,
          ),
        );
        throw Exception(
            'Validation failed with errors: ${getErrors().map((e) => e.toString()).toList()}');
      }
    }
    // If the value is already a DateTime, defer to the base implementation.
    final result = super.parse(value);
    return result as DateTime;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value, {String fieldName = ''}) {
    try {
      final parsed = parse(value, fieldName: fieldName);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {'success': false, 'errors': getErrors()};
    }
  }
}
