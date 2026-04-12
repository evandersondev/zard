import 'package:zard/src/types/zard_issue.dart';

import '../types/zard_error.dart';
import 'schema.dart';

abstract interface class ZBool extends Schema<bool> {
  final String? message;

  ZBool({this.message});
  // No constructor validator needed — the parse() override handles type checking.

  @override
  bool parse(dynamic value, {String path = ''}) {
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

    if (value is! bool) {
      addError(ZardIssue(
        message: message ?? 'Expected a boolean value',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
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
  Future<bool> parseAsync(dynamic value, {String path = ''}) async {
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue, path: path);
  }
}

class ZCoerceBoolean extends ZBool {
  ZCoerceBoolean({super.message});

  @override
  bool parse(dynamic value, {String path = ''}) {
    clearErrors();
    if (value == 0 ||
        value == '0' ||
        value == false ||
        value == null ||
        value == '') {
      return false;
    }
    return true;
  }
}

class ZBoolImpl extends ZBool {
  ZBoolImpl({super.message});
}
