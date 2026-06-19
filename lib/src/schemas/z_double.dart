import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZDouble extends Schema<double> {
  final String? message;

  ZDouble({this.message});

  ZDouble min(num minValue, {String? message}) {
    addCheck('minimum', minValue);
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
    addCheck('maximum', maxValue);
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
    addCheck('exclusiveMinimum', 0);
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
    addCheck('minimum', 0);
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
    addCheck('exclusiveMaximum', 0);
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
    addCheck('multipleOf', divisor);
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
  double? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final pathOrNull = path.isEmpty ? null : path;

    if (value == null) {
      sink.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    if (value is! double) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a double value',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    final beforeLen = sink.length;
    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](value);
      if (error != null) {
        if (pathOrNull == null && error.value == value) {
          sink.add(error);
        } else {
          sink.add(ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: pathOrNull,
          ));
        }
      }
    }
    if (sink.length != beforeLen) return null;

    var result = value;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      result = transforms[i](result);
    }
    return result;
  }

  @override
  double parse(dynamic value, {String path = ''}) {
    clearErrors();
    final pathOrNull = path.isEmpty ? null : path;
    final sink = issuesInternal;

    if (value == null) {
      sink.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(sink);
    }

    if (value is! double) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a double value',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(sink);
    }

    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](value);
      if (error != null) {
        if (pathOrNull == null && error.value == value) {
          sink.add(error);
        } else {
          sink.add(ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: pathOrNull,
          ));
        }
      }
    }

    if (sink.isNotEmpty) {
      throw ZardError(sink);
    }

    var result = value;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      result = transforms[i](result);
    }

    return result;
  }
}

class ZCoerceDouble extends ZDouble {
  ZCoerceDouble({super.message});

  // ZDouble overrides parseInto with a non-coercing fast path, so container
  // schemas (ZMap, ZList) would bypass coercion. Delegate back to our
  // coercing parse() — mirrors the default Schema.parseInto behavior.
  @override
  double? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    try {
      return parse(value, path: path);
    } on ZardError catch (e) {
      sink.addAll(e.issues);
      return null;
    }
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
