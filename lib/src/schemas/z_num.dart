import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZNum extends Schema<num> {
  final String? message;

  ZNum({this.message});

  ZNum min(num minValue, {String? message}) {
    addValidator((num value) {
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

  ZNum max(num maxValue, {String? message}) {
    addValidator((num value) {
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

  ZNum positive({String? message}) {
    addValidator((num value) {
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

  ZNum nonnegative({String? message}) {
    addValidator((num value) {
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

  ZNum negative({String? message}) {
    addValidator((num value) {
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

  ZNum multipleOf(num divisor, {String? message}) {
    addValidator((num value) {
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

  ZNum step(num stepValue, {String? message}) {
    return multipleOf(stepValue, message: message);
  }

  @override
  num parse(dynamic value, {String path = ''}) {
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

    if (value is! num) {
      addError(ZardIssue(
        message: message ?? 'Expected a num value',
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

class ZCoerceNum extends ZNum {
  ZCoerceNum({super.message});

  @override
  num parse(dynamic value, {String path = ''}) {
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

    num? coercedValue;
    if (value is num) {
      coercedValue = value;
    } else {
      try {
        coercedValue = num.tryParse(value.toString());
      } catch (_) {}
    }

    if (coercedValue == null) {
      addError(ZardIssue(
        message: message ?? 'Failed to coerce value to a number',
        type: 'coerce_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    return super.parse(coercedValue, path: path);
  }
}

class ZNumImpl extends ZNum {
  ZNumImpl({super.message});
}
