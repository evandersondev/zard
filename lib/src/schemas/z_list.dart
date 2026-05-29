import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

typedef ListValidator = ZardIssue? Function(List<dynamic> value);

abstract interface class ZList extends Schema<List<dynamic>> {
  final Schema _itemSchema;
  final List<ListValidator> _listValidators = [];
  final String? message;

  ZList(this._itemSchema, {this.message});

  /// The schema applied to each item.
  ///
  /// Exposed for introspection (e.g. generating OpenAPI / JSON Schema).
  Schema get element => _itemSchema;

  @override
  void addValidator(covariant ListValidator validator) {
    _listValidators.add(validator);
  }

  @override
  List<dynamic>? parseInto(
      dynamic value, String path, List<ZardIssue> sink) {
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
    if (value is! List) {
      sink.add(ZardIssue(
        message: message ?? 'Must be a list',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    final beforeOuter = sink.length;
    final len = value.length;
    final result = List<dynamic>.filled(len, null, growable: false);
    for (var i = 0; i < len; i++) {
      final before = sink.length;
      final parsed = _itemSchema.parseInto(
        value[i],
        path.isEmpty ? '[$i]' : '$path[$i]',
        sink,
      );
      if (sink.length == before) {
        result[i] = parsed;
      }
    }

    final listValidators = _listValidators;
    for (var i = 0; i < listValidators.length; i++) {
      final error = listValidators[i](result);
      if (error != null) {
        sink.add(ZardIssue(
          message: error.message,
          type: error.type,
          value: result,
          path: pathOrNull,
        ));
      }
    }

    if (sink.length != beforeOuter) return null;

    var transformedResult = result;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      transformedResult = transforms[i](transformedResult);
    }
    return transformedResult;
  }

  @override
  List<dynamic> parse(dynamic value, {String path = ''}) {
    // A LOCAL issues list is intentional — recursive schema invocations
    // (e.g. via lazy circular references) reset the shared _ctx, which would
    // otherwise wipe this call's errors mid-iteration.
    final localIssues = <ZardIssue>[];
    final pathOrNull = path.isEmpty ? null : path;

    if (value == null) {
      throw ZardError([
        ZardIssue(
          message: message ?? 'Value is required and cannot be null',
          type: 'required_error',
          value: value,
          path: pathOrNull,
        )
      ]);
    }

    if (value is! List) {
      throw ZardError([
        ZardIssue(
          message: message ?? 'Must be a list',
          type: 'type_error',
          value: value,
          path: pathOrNull,
        )
      ]);
    }

    final len = value.length;
    final result = List<dynamic>.filled(len, null, growable: false);
    for (var i = 0; i < len; i++) {
      final before = localIssues.length;
      final parsed = _itemSchema.parseInto(
        value[i],
        path.isEmpty ? '[$i]' : '$path[$i]',
        localIssues,
      );
      if (localIssues.length == before) {
        result[i] = parsed;
      }
    }

    final listValidators = _listValidators;
    for (var i = 0; i < listValidators.length; i++) {
      final error = listValidators[i](result);
      if (error != null) {
        localIssues.add(ZardIssue(
          message: error.message,
          type: error.type,
          value: result,
          path: pathOrNull,
        ));
      }
    }

    if (localIssues.isNotEmpty) {
      throw ZardError(localIssues);
    }

    var transformedResult = result;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      transformedResult = transforms[i](transformedResult);
    }

    return transformedResult;
  }

  ZList noempty({String? message}) {
    addValidator((List<dynamic> value) {
      if (value.isEmpty) {
        return ZardIssue(
          message: message ?? 'List must not be empty',
          type: 'noempty_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  ZList min(int min, {String? message}) {
    addValidator((List<dynamic> value) {
      if (value.length < min) {
        return ZardIssue(
          message: message ?? 'List must have at least $min items',
          type: 'min_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  ZList max(int max, {String? message}) {
    addValidator((List<dynamic> value) {
      if (value.length > max) {
        return ZardIssue(
          message: message ?? 'List must have at most $max items',
          type: 'max_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  ZList lenght(int length, {String? message}) {
    addValidator((List<dynamic> value) {
      if (value.length != length) {
        return ZardIssue(
          message: message ?? 'List must have exactly $length items',
          type: 'length_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }
}

class ZListImpl extends ZList {
  ZListImpl(super._itemSchema, {super.message});
}
