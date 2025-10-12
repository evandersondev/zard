import 'package:zard/src/types/zard_issue.dart';

import '../types/zard_error.dart';
import 'schema.dart';

class ZBool extends Schema<bool> {
  final String? message;

  ZBool({this.message}) {
    addValidator((bool? value) {
      if (value != true && value != false) {
        return ZardIssue(
          message: message ?? 'Expected a boolean value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  @override
  bool parse(dynamic value, {String path = '', ErrorMap? error}) {
    clearErrors();

    if (value is! bool) {
      addError(
        ZardIssue(
          message: message ?? 'Expected a boolean value',
          type: 'type_error',
          value: value,
        ),
        customErrorMap: error,
      );
      throw ZardError(issues);
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(error);
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    var transformedValue = value;
    for (final transform in getTransforms()) {
      transformedValue = transform(transformedValue);
    }

    return transformedValue;
  }

  @override
  Future<bool> parseAsync(dynamic value, {String? path}) async {
    clearErrors();
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue);
  }
}

class ZCoerceBoolean extends Schema<bool> {
  ZCoerceBoolean({String? message});

  @override
  bool parse(dynamic value, {String path = '', ErrorMap? error}) {
    clearErrors();
    try {
      if (value == 0 || value == '0' || value == '' || value == false || value == null) {
        return false;
      }
      return true;
    } catch (e) {
      addError(ZardIssue(
        message: 'Failed to coerce value to boolean',
        type: 'coerce_error',
        value: value,
        path: path,
      ));
      throw ZardError(issues);
    }
  }
}
