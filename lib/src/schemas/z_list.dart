import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

typedef ListValidator = ZardIssue? Function(List<dynamic> value);

class ZList extends Schema<List<dynamic>> {
  final Schema _itemSchema;
  final List<ListValidator> _validators = [];
  final String? message;

  ZList(this._itemSchema, {this.message});

  @override
  void addValidator(ListValidator validator) {
    _validators.add(validator);
  }

  @override
  List<dynamic> parse(dynamic value, {String path = '', ErrorMap? error}) {
    clearErrors();

    if (value is! List) {
      addError(
        ZardIssue(
          message: message ?? 'Must be a list',
          type: 'type_error',
          value: value,
          path: path,
        ),
      );
      throw ZardError(issues);
    }

    final result = <dynamic>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      try {
        final parsedItem = _itemSchema.parse(item);
        result.add(parsedItem);
      } catch (e) {
        issues.addAll(_itemSchema.getErrors());
      }
    }

    for (final validator in _validators) {
      final error = validator(result);
      if (error != null) {
        addError(error);
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    var transformedResult = result;
    for (final transform in getTransforms()) {
      transformedResult = transform(transformedResult);
    }

    return transformedResult;
  }

  /// Noempty validation
  /// Example:
  /// ```dart
  /// final listSchema = z.list(z.string()).noempty();
  /// final list = listSchema.parse(['a', 'b', '2']);
  /// print(list); // Output: ['a', 'b', '2']
  /// final listEmpty = listSchema.parse([]);
  /// // Throws with error details
  /// ```
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

  /// Min validation
  /// Example:
  /// ```dart
  /// final listSchema = z.list(z.string()).min(2);
  /// final list = listSchema.parse(['a', 'b', '2']);
  /// print(list); // Output: ['a', 'b', '2']
  /// final listShort = listSchema.parse(['a']);
  /// // Throws with error details
  /// ```
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

  /// Max validation
  /// Example:
  /// ```dart
  /// final listSchema = z.list(z.string()).max(2);
  /// final list = listSchema.parse(['a', 'b']);
  /// print(list); // Output: ['a', 'b']
  /// final listLong = listSchema.parse(['a', 'b', 'c']);
  /// // Throws with error details
  /// ```
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

  /// Length validation
  /// Example:
  /// ```dart
  /// final listSchema = z.list(z.string()).lenght(2);
  /// final list = listSchema.parse(['a', 'b']);
  /// print(list); // Output: ['a', 'b']
  /// final listInvalid = listSchema.parse(['a', 'b', 'c']);
  /// // Throws with error details
  /// ```
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
