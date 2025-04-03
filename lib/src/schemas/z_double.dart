import '../types/zart_error.dart';
import 'schema.dart';

class ZDouble extends Schema<double> {
  ZDouble({String? message}) {
    addValidator((double? value) {
      if (value == null) {
        return ZardError(
          message: message ?? 'Expected a double value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  /// Min validation for double values.
  /// Example:
  /// ```dart
  /// final schema = z.double().min(10);
  /// schema.parse(5.0); // throws error
  /// schema.parse(15.0); // returns 15.0
  /// ```
  ZDouble min(num minValue, {String? message}) {
    addValidator((double? value) {
      if (value != null && value < minValue) {
        return ZardError(
          message: message ?? 'Value must be at least $minValue',
          type: 'min_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Max validation for double values.
  /// Example:
  /// ```dart
  /// final schema = z.double().max(10);
  /// schema.parse(5.0); // returns 5.0
  /// schema.parse(15.0); // throws error
  /// ```
  ZDouble max(num maxValue, {String? message}) {
    addValidator((double? value) {
      if (value != null && value > maxValue) {
        return ZardError(
          message: message ?? 'Value must be at most $maxValue',
          type: 'max_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is positive (> 0).
  /// Example:
  /// ```dart
  /// final schema = z.double().positive();
  /// schema.parse(5.0); // returns 5.0
  /// schema.parse(-5.0); // throws error
  /// schema.parse(0.0); // throws error
  /// ```
  ZDouble positive({String? message}) {
    addValidator((double? value) {
      if (value != null && value <= 0.0) {
        return ZardError(
          message: message ?? 'Value must be greater than 0',
          type: 'positive_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is nonnegative (>= 0).
  /// Example:
  /// ```dart
  /// final schema = z.double().nonnegative();
  /// schema.parse(5.0); // returns 5.0
  /// schema.parse(-5.0); // throws error
  /// schema.parse(0.0); // returns 0.0
  /// ```
  ZDouble nonnegative({String? message}) {
    addValidator((double? value) {
      if (value != null && value < 0.0) {
        return ZardError(
          message: message ?? 'Value must be nonnegative (>= 0)',
          type: 'nonnegative_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is negative (< 0).
  /// Example:
  /// ```dart
  /// final schema = z.double().negative();
  /// schema.parse(5.0); // throws error
  /// schema.parse(-5.0); // returns -5.0
  /// schema.parse(0.0); // throws error
  /// ```
  ZDouble negative({String? message}) {
    addValidator((double? value) {
      if (value != null && value >= 0.0) {
        return ZardError(
          message: message ?? 'Value must be negative (< 0)',
          type: 'negative_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is a multiple of the given divisor.
  /// Example:
  /// ```dart
  /// final schema = z.double().multipleOf(2);
  /// schema.parse(4.0); // returns 4.0
  /// schema.parse(5.0); // throws error
  /// schema.parse(6.0); // returns 6.0
  /// schema.parse(7.0); // throws error
  /// ```
  ZDouble multipleOf(double divisor, {String? message}) {
    addValidator((double? value) {
      if (value != null) {
        final remainder = value % divisor;
        if (remainder.abs() > 1e-10) {
          return ZardError(
            message: message ?? 'Value must be a multiple of $divisor',
            type: 'multiple_of_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is a multiple of the given step value.
  /// Example:
  /// ```dart
  /// final schema = z.double().step(2);
  /// schema.parse(4.0); // returns 4.0
  /// schema.parse(5.0); // throws error
  /// schema.parse(6.0); // returns 6.0
  /// schema.parse(7.0); // throws error
  /// ```
  ZDouble step(double stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  double parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! double) {
      addError(
        ZardError(
          message: 'Expected a double value',
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
        addError(
          ZardError(
            message: error.message,
            type: error.type,
            value: value,
          ),
        );
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    var result = value;
    for (final transform in getTransforms()) {
      result = transform(result);
    }

    return result;
  }
}

class ZCoerceDouble extends Schema<double> {
  ZCoerceDouble({String? message});

  @override
  double parse(dynamic value, {String fieldName = ''}) {
    clearErrors();
    try {
      final asString = value?.toString() ?? '';
      double? result = double.tryParse(asString);
      if (result == null) {
        throw Exception();
      }
      for (final transform in getTransforms()) {
        result = transform(result!);
      }
      return result!;
    } catch (e) {
      addError(ZardError(
        message: 'Failed to coerce value to number',
        type: 'coerce_error',
        value: value,
      ));
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }
  }

  @override
  Map<String, dynamic> safeParse(dynamic value, {String fieldName = ''}) {
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
