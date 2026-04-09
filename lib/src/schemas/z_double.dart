import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZDouble extends Schema<double> {
  final String? message;

  ZDouble({this.message});

  ZDouble min(num minValue, {String? message}) {
    addValidator((double value) {
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

  ZDouble max(num maxValue, {String? message}) {
    addValidator((double value) {
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

  ZDouble positive({String? message}) {
    addValidator((double value) {
      if (value <= 0.0) {
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

  ZDouble nonnegative({String? message}) {
    addValidator((double value) {
      if (value < 0.0) {
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

  ZDouble negative({String? message}) {
    addValidator((double value) {
      if (value >= 0.0) {
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

  ZDouble multipleOf(double divisor, {String? message}) {
    addValidator((double value) {
      final remainder = value % divisor;
      if (remainder.abs() > 1e-10) {
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

  ZDouble step(double stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  double parse(dynamic value, {String path = ''}) {
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

    if (value is! double) {
      addError(ZardIssue(
        message: message ?? 'Expected a double value',
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

class ZCoerceDouble extends ZDouble {
  ZCoerceDouble({super.message});

  @override
  double parse(dynamic value, {String path = ''}) {
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

    double? coercedValue;
    try {
      coercedValue = double.tryParse(value.toString());
    } catch (_) {}

    if (coercedValue == null) {
      addError(ZardIssue(
        message: message ?? 'Failed to coerce value to double',
        type: 'coerce_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    return super.parse(coercedValue, path: path);
  }
}

class ZDoubleImpl extends ZDouble {
  ZDoubleImpl({super.message});
}
