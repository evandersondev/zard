import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

typedef ListValidator = ZardIssue? Function(List<dynamic> value);

abstract interface class ZList extends Schema<List<dynamic>> {
  final Schema _itemSchema;
  final List<ListValidator> _listValidators = [];
  final String? message;

  ZList(this._itemSchema, {this.message});

  @override
  void addValidator(covariant ListValidator validator) {
    _listValidators.add(validator);
  }

  @override
  List<dynamic> parse(dynamic value, {String path = ''}) {
    // Use a LOCAL issues list so that recursive schema invocations (e.g. via
    // lazy circular references) cannot corrupt this call's error state by
    // replacing the shared _ctx via clearErrors().
    final localIssues = <ZardIssue>[];

    if (value == null) {
      localIssues.add(ZardIssue(
        message: message ?? 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    if (value is! List) {
      localIssues.add(ZardIssue(
        message: message ?? 'Must be a list',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(localIssues);
    }

    final result = <dynamic>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      final itemPath = path.isEmpty ? '[$i]' : '$path[$i]';
      try {
        result.add(_itemSchema.parse(item, path: itemPath));
      } on ZardError catch (e) {
        localIssues.addAll(e.issues);
      }
    }

    for (final validator in _listValidators) {
      final error = validator(result);
      if (error != null) {
        localIssues.add(ZardIssue(
          message: error.message,
          type: error.type,
          value: result,
          path: path.isEmpty ? null : path,
        ));
      }
    }

    if (localIssues.isNotEmpty) {
      throw ZardError(localIssues);
    }

    var transformedResult = result;
    for (final transform in getTransforms()) {
      transformedResult = transform(transformedResult);
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
