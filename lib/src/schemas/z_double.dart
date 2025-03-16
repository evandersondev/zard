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

  ZDouble min(double length, {String? message}) {
    addValidator((double? value) {
      if (value != null && value < length) {
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

  ZDouble max(double length, {String? message}) {
    addValidator((double? value) {
      if (value != null && value > length) {
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

  // Ensures the value is positive (> 0).
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

  // Ensures the value is nonnegative (>= 0).
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

  // Ensures the value is negative (< 0).
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

  // Ensures the value is a multiple of the given divisor.
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

  // Alias for multipleOf.
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
