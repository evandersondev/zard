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

  ZInt min(int length, {String? message}) {
    addValidator((int? value) {
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

  ZInt max(int length, {String? message}) {
    addValidator((int? value) {
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

  // Ensures the value is nonnegative (>= 0).
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

  // Ensures the value is negative (< 0).
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

  // Ensures the value is a multiple of the given divisor.
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

  // Alias for multipleOf.
  ZInt step(int stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  int? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! int) {
      addError(
        ZardError(
          message: 'Expected an integer value',
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
