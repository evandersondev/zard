import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schemas.dart';

abstract interface class ZStringBool extends Schema<bool> {
  final String? message;

  ZStringBool({this.message});

  @override
  bool parse(dynamic value, {String path = ''}) {
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
    } catch (_) {}

    if (parsed == null) {
      addError(ZardIssue(
        message: message ?? 'Expected a boolean-like string',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(issues);
    }

    return parsed;
  }

  @override
  Future<bool> parseAsync(dynamic value, {String path = ''}) async {
    final resolvedValue = value is Future ? await value : value;
    return parse(resolvedValue, path: path);
  }
}

/// Coercion boolean: falsy values → false, everything else → true.
class ZCoerceBoolean extends ZStringBool {
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

class ZStringBoolImpl extends ZStringBool {
  ZStringBoolImpl({super.message});
}
