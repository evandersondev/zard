import '../types/zart_error.dart';
import 'schema.dart';

class ZInt extends Schema<int> {
  ZInt({String? message}) {
    addValidator((int? value) {
      if (value == null) {
        return ZardError(
          message: message ?? 'Expected an integer value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  /// Min validation for int values.
  /// Example:
  /// ```dart
  /// final schema = z.int().min(10);
  /// schema.parse(5); // throws error
  /// schema.parse(15); // returns 15
  /// ```
  ZInt min(int minValue, {String? message}) {
    addValidator((int? value) {
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

  /// Max validation for int values.
  /// Example:
  /// ```dart
  /// final schema = z.int().max(10);
  /// schema.parse(5); // returns 5
  /// schema.parse(15); // throws error
  /// ```
  ZInt max(int maxValue, {String? message}) {
    addValidator((int? value) {
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
  /// final schema = z.int().positive();
  /// schema.parse(5); // returns 5
  /// schema.parse(-5); // throws error
  /// schema.parse(0); // throws error
  /// ```
  ZInt positive({String? message}) {
    addValidator((int? value) {
      if (value != null && value <= 0) {
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
  /// final schema = z.int().nonnegative();
  /// schema.parse(5); // returns 5
  /// schema.parse(-5); // throws error
  /// schema.parse(0); // returns 0
  /// ```
  ZInt nonnegative({String? message}) {
    addValidator((int? value) {
      if (value != null && value < 0) {
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
  /// final schema = z.int().negative();
  /// schema.parse(5); // throws error
  /// schema.parse(-5); // returns -5
  /// schema.parse(0); // throws error
  /// ```
  ZInt negative({String? message}) {
    addValidator((int? value) {
      if (value != null && value >= 0) {
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

  /// Ensures the value is a multiple of a given divisor.
  /// Example:
  /// ```dart
  /// final schema = z.int().multipleOf(3);
  /// schema.parse(6); // returns 6
  /// schema.parse(7); // throws error
  /// schema.parse(9); // returns 9
  /// schema.parse(10); // throws error
  /// ```
  ZInt multipleOf(int divisor, {String? message}) {
    addValidator((int? value) {
      if (value != null && value % divisor != 0) {
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

  /// Ensures the value is a step of a given step value.
  /// Example:
  /// ```dart
  /// final schema = z.int().step(3);
  /// schema.parse(6); // returns 6
  /// schema.parse(7); // throws error
  /// schema.parse(9); // returns 9
  /// schema.parse(10); // throws error
  /// ```
  ZInt step(int stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  int? parse(dynamic value) {
    clearErrors();

    if (value is! int) {
      addError(
        ZardError(
          message: 'Expected an integer value',
          type: 'type_error',
          value: value,
        ),
      );
      throw Exception(
        'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}',
      );
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
      throw Exception(
        'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}',
      );
    }

    var result = value;
    for (final transform in getTransforms()) {
      result = transform(result);
    }

    return result;
  }
}

class ZCoerceInt extends Schema<int> {
  ZCoerceInt({String? message});

  @override
  int parse(dynamic value) {
    clearErrors();
    try {
      final asString = value?.toString() ?? '';
      int result = int.parse(asString);
      for (final transform in getTransforms()) {
        result = transform(result);
      }
      return result;
    } catch (e) {
      addError(ZardError(
        message: 'Failed to coerce value to BigInt',
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
