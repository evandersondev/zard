import '../types/zart_error.dart';
import 'schema.dart';

typedef ListValidator = ZardError? Function(List<dynamic> value);

class ZList extends Schema<List<dynamic>> {
  final Schema _itemSchema;
  final List<ListValidator> _validators = [];

  ZList(this._itemSchema);

  @override
  void addValidator(ListValidator validator) {
    _validators.add(validator);
  }

  @override
  List<dynamic>? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! List) {
      addError(
        ZardError(message: 'Must be a list', type: 'type_error', value: value),
      );
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    final result = <dynamic>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      try {
        final parsedItem = _itemSchema.parse(item);
        result.add(parsedItem);
      } catch (e) {
        // Acumula os erros do item
        errors.addAll(_itemSchema.getErrors());
      }
    }

    for (final validator in _validators) {
      final error = validator(result);
      if (error != null) {
        addError(error);
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    // Aplica as transformações (caso existam) no resultado final
    var transformedResult = result;
    for (final transform in getTransforms()) {
      transformedResult = transform(transformedResult);
    }

    return transformedResult;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    try {
      final parsed = parse(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {
        'success': false,
        'errors': errors.map((e) => e.toString()).toList()
      };
    }
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
        return ZardError(
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
        return ZardError(
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
        return ZardError(
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
        return ZardError(
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
