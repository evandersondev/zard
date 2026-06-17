import 'package:zard/src/types/zard_issue.dart';

import '../types/zard_error.dart';
import 'schema.dart';

abstract interface class ZBool extends Schema<bool> {
  final String? message;

  ZBool({this.message});
  // No constructor validator needed — the parse() override handles type checking.

  @override
  bool? parseInto(dynamic value, String path, List<ZardIssue> sink) {
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

    if (value is! bool) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a boolean value',
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
      if (error != null) sink.add(error);
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
  bool parse(dynamic value, {String path = ''}) {
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

    if (value is! bool) {
      sink.add(ZardIssue(
        message: message ?? 'Expected a boolean value',
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
        sink.add(error);
      }
    }

    if (sink.isNotEmpty) {
      throw ZardError(sink);
    }

    var transformedValue = value;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      transformedValue = transforms[i](transformedValue);
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

  // ZBool overrides parseInto with a non-coercing fast path, so container
  // schemas (ZMap, ZList) would bypass coercion. Delegate back to our
  // coercing parse() — mirrors the default Schema.parseInto behavior.
  @override
  bool? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    try {
      return parse(value, path: path);
    } on ZardError catch (e) {
      sink.addAll(e.issues);
      return null;
    }
  }

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
