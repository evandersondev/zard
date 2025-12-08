import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schemas.dart';

abstract interface class ZStringBool extends Schema<bool> {
  final String? message;

  ZStringBool({this.message}) {
    // Accept various string/boolean-like inputs; actual validation is performed in parse().
  }

  @override
  bool parse(dynamic value, {String? path}) {
    clearErrors();

    bool? parsed;

    try {
      if (value is bool) {
        parsed = value;
      } else if (value is num) {
        if (value == 1) parsed = true;
        if (value == 0) parsed = false;
      } else if (value is String) {
        final s = value.trim().toLowerCase();
        const trueSet = {'1', 'true', 'yes', 'on', 'y', 'enabled'};
        const falseSet = {'0', 'false', 'no', 'off', 'n', 'disabled'};

        if (trueSet.contains(s)) {
          parsed = true;
        } else if (falseSet.contains(s) || s == '') {
          parsed = false;
        }
      }
    } catch (_) {
      // ignore and let parsed remain null
    }

    if (parsed == null) {
      addError(ZardIssue(
        message: message ?? 'Expected a boolean-like string',
        type: 'type_error',
        value: value,
        path: path,
      ));
      throw ZardError(issues);
    }

    return parsed;
  }

  @override
  Future<bool> parseAsync(dynamic value, {String? path}) async {
    clearErrors();
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue);
  }
}

class ZCoerceBoolean extends ZStringBool {
  ZCoerceBoolean({super.message});

  @override
  bool parse(dynamic value, {String? path}) {
    clearErrors();
    try {
      if (value == 0 ||
          value == '0' ||
          value == false ||
          value == null ||
          value == '') {
        return false;
      }
      return true;
    } catch (e) {
      // This logic is simple enough that it shouldn't throw.
      // The super.parse will handle any final type checks.
    }
    return super.parse(value, path: path);
  }
}

class ZStringBoolImpl extends ZStringBool {
  ZStringBoolImpl({super.message});
}
