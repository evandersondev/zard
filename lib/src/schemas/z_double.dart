// ignore_for_file: unnecessary_type_check

import '../types/zart_error.dart';

import 'schema.dart';

class ZDouble extends Schema<double> {
  ZDouble({String? message}) {
    addValidator((double? value) {
      if (value == null || value is! double) {
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
  /// schema.parse(5.0); // returns null
  /// schema.parse(15.0); // returns 15
  /// ```
  ZDouble min(int length, {String? message}) {
    addValidator((double? value) {
      if (value != null && value < double.parse(length.toString())) {
        return ZardError(
          message: message ?? 'Value must be at least $length',
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
  /// schema.parse(5.0); // returns 5
  /// schema.parse(15.0); // returns null
  /// ```
  ZDouble max(int length, {String? message}) {
    addValidator((double? value) {
      if (value != null && value > double.parse(length.toString())) {
        return ZardError(
          message: message ?? 'Value must be at most $length',
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
  /// schema.parse(5.0); // returns 5
  /// schema.parse(-5.0); // returns null
  /// schema.parse(0.0); // returns null
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
  /// schema.parse(5.0); // returns 5
  /// schema.parse(-5.0); // returns null
  /// schema.parse(0.0); // returns 0
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
  /// schema.parse(5.0); // returns null
  /// schema.parse(-5.0); // returns -5
  /// schema.parse(0.0); // returns null
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
  /// schema.parse(4.0); // returns 4
  /// schema.parse(5.0); // returns null
  /// schema.parse(6.0); // returns 6
  /// schema.parse(7.0); // returns null
  /// ```
  ZDouble multipleOf(double divisor, {String? message}) {
    addValidator((double? value) {
      final remainder = value != null ? value % divisor : double.nan;
      // Use a tolerance for floating point comparisons.
      if (remainder.abs() > 1e-10) {
        return ZardError(
          message: message ?? 'Value must be a multiple of $divisor',
          type: 'multiple_of_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Ensures the value is a multiple of the given step value.
  /// Example:
  /// ```dart
  /// final schema = z.double().step(2);
  /// schema.parse(4.0); // returns 4
  /// schema.parse(5.0); // returns null
  /// schema.parse(6.0); // returns 6
  /// schema.parse(7.0); // returns null
  /// ```
  ZDouble step(double stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  double? parse(dynamic value) {
    clearErrors();

    if (value is! double) {
      addError(
        ZardError(
          message: 'Expected a double value',
          type: 'type_error',
          value: value,
        ),
      );
      return null;
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(
          ZardError(message: error.message, type: error.type, value: value),
        );
      }
    }

    if (errors.isNotEmpty) {
      return null;
    }

    return value;
  }
}
