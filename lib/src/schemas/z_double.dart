import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZDouble extends Schema<double> {
  final String? message;

  ZDouble({this.message}) {
    addValidator((double? value) {
      if (value == null) {
        return ZardIssue(
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
        return ZardIssue(
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
        return ZardIssue(
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
        return ZardIssue(
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
        return ZardIssue(
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
        return ZardIssue(
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
          return ZardIssue(
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
  double parse(dynamic value, {String? path}) {
    clearErrors();

    if (value is! double) {
      addError(
        ZardIssue(
          message: message ?? 'Expected a double value',
          type: 'type_error',
          value: value,
          path: path,
        ),
      );
      throw ZardError(issues);
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(
          ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: path,
          ),
        );
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    var result = value;
    for (final transform in getTransforms()) {
      result = transform(result);
    }

    return result;
  }
}

class ZCoerceDouble extends ZDouble {
  ZCoerceDouble({super.message});

  @override
  double parse(dynamic value, {String? path}) {
    clearErrors();

    double? coercedValue;

    try {
      final asString = value?.toString() ?? '';
      coercedValue = double.tryParse(asString);
    } catch (e) {
      // Let the super.parse handle the error reporting
    }

    if (coercedValue == null) {
      addError(ZardIssue(
        message: message ?? 'Failed to coerce value to double',
        type: 'coerce_error',
        value: value,
        path: path,
      ));
      throw ZardError(issues);
    }

    // Now that we have a double, we can run the validators from the parent ZDouble class.
    // We call super.parse() to run all the validations (min, max, etc.)
    // that might have been chained.
    try {
      return super.parse(coercedValue, path: path);
    } on ZardError catch (e) {
      // Re-throw the error to propagate it up.
      throw e;
    }
  }
}

class ZDoubleImpl extends ZDouble {
  ZDoubleImpl({super.message});
}
