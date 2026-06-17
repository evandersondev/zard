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
  num? parseInto(dynamic value, String path, List<ZardIssue> sink) {
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

    if (value is! num) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a num value',
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
  num parse(dynamic value, {String path = ''}) {
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

    if (value is! num) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a num value',
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

class ZCoerceNum extends ZNum {
  ZCoerceNum({super.message});

  // ZNum overrides parseInto with a non-coercing fast path, so container
  // schemas (ZMap, ZList) would bypass coercion. Delegate back to our
  // coercing parse() — mirrors the default Schema.parseInto behavior.
  @override
  num? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    try {
      return parse(value, path: path);
    } on ZardError catch (e) {
      sink.addAll(e.issues);
      return null;
    }
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
