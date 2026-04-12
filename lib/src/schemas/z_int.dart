import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZInt extends Schema<int> {
  final String? message;

  ZInt({this.message});

  ZInt min(int minValue, {String? message}) {
    addValidator((int value) {
      if (value < minValue) {
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

  ZInt max(int maxValue, {String? message}) {
    addValidator((int value) {
      if (value > maxValue) {
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

  ZInt positive({String? message}) {
    addValidator((int value) {
      if (value <= 0) {
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

  ZInt nonnegative({String? message}) {
    addValidator((int value) {
      if (value < 0) {
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

  ZInt negative({String? message}) {
    addValidator((int value) {
      if (value >= 0) {
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

  ZInt multipleOf(int divisor, {String? message}) {
    addValidator((int value) {
      if (value % divisor != 0) {
        return ZardIssue(
          message: message ?? 'Value must be a multiple of $divisor',
          type: 'multiple_of_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  ZInt step(int stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  int parse(dynamic value, {String path = ''}) {
    clearErrors();

    if (value == null) {
      addError(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    if (value is! int) {
      addError(ZardIssue(
        message: message ?? 'Expected an integer value',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(ZardIssue(
          message: error.message,
          type: error.type,
          value: value,
          path: path.isEmpty ? null : path,
        ));
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

class ZCoerceInt extends ZInt {
  ZCoerceInt({super.message});

  @override
  int parse(dynamic value, {String path = ''}) {
    clearErrors();

    if (value == null) {
      addError(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    int? coercedValue;
    try {
      coercedValue = int.tryParse(value.toString());
    } catch (_) {}

    if (coercedValue == null) {
      addError(ZardIssue(
        message: message ?? 'Failed to coerce value to int',
        type: 'coerce_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    return super.parse(coercedValue, path: path);
  }
}

class ZIntImpl extends ZInt {
  ZIntImpl({super.message});
}
