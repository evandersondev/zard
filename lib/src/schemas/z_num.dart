import 'package:zard/src/types/zard_issue.dart';

import '../types/zard_error.dart';
import 'schema.dart';

class ZNum extends Schema<num> {
  final String? message;

  ZNum({this.message}) {
    addValidator((num? value) {
      if (value == null) {
        return ZardIssue(
          message: message ?? 'Expected a num value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  /// Min validation for num values.
  /// Example:
  /// ```dart
  /// final schema = z.num().min(10);
  /// schema.parse(5); // throws error
  /// schema.parse(15); // returns 15
  /// ```
  ZNum min(num minValue, {String? message}) {
    addValidator((num? value) {
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

  /// Max validation for num values.
  /// Example:
  /// ```dart
  /// final schema = z.num().max(10);
  /// schema.parse(5); // returns 5
  /// schema.parse(15); // throws error
  /// ```
  ZNum max(num maxValue, {String? message}) {
    addValidator((num? value) {
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
  /// final schema = z.num().positive();
  /// schema.parse(5); // returns 5
  /// schema.parse(-5); // throws error
  /// schema.parse(0); // throws error
  /// ```
  ZNum positive({String? message}) {
    addValidator((num? value) {
      if (value != null && value <= 0) {
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
  /// final schema = z.num().nonnegative();
  /// schema.parse(5); // returns 5
  /// schema.parse(-5); // throws error
  /// schema.parse(0); // returns 0
  /// ```
  ZNum nonnegative({String? message}) {
    addValidator((num? value) {
      if (value != null && value < 0) {
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
  /// final schema = z.num().negative();
  /// schema.parse(5); // throws error
  /// schema.parse(-5); // returns -5
  /// schema.parse(0); // throws error
  /// ```
  ZNum negative({String? message}) {
    addValidator((num? value) {
      if (value != null && value >= 0) {
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
  /// final schema = z.num().multipleOf(2);
  /// schema.parse(4); // returns 4
  /// schema.parse(5); // throws error
  /// schema.parse(6); // returns 6
  /// schema.parse(7); // throws error
  /// ```
  ZNum multipleOf(num divisor, {String? message}) {
    addValidator((num? value) {
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
  /// final schema = z.num().step(2);
  /// schema.parse(4); // returns 4
  /// schema.parse(5); // throws error
  /// schema.parse(6); // returns 6
  /// schema.parse(7); // throws error
  /// ```
  ZNum step(num stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  num parse(dynamic value, {String? path}) {
    clearErrors();

    // Accept both int and double (both are num)
    if (value is! num) {
      addError(
        ZardIssue(
          message: message ?? 'Expected a num value',
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
