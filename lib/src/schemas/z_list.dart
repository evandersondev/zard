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
      return null;
    }

    final result = <dynamic>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      final parsedItem = _itemSchema.parse(item);
      if (parsedItem == null && _itemSchema.getErrors().isNotEmpty) {
        errors.addAll(_itemSchema.getErrors());
      } else {
        result.add(parsedItem);
      }
    }

    // Executa os validadores registrados. Se algum retornar erro,
    // esse erro é adicionado à lista de erros.
    for (final validator in _validators) {
      final error = validator(result);
      if (error != null) {
        addError(error);
      }
    }

    return errors.isNotEmpty ? null : result;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    final parsed = parse(value);
    if (parsed == null) {
      return {'success': false, 'errors': getErrors()};
    }
    return {'success': true, 'data': parsed};
  }

  /// Validação que garante que a lista não esteja vazia.
  ///
  /// Exemplo:
  /// final listSchema = z.list(z.string()).noempty();
  /// final list = listSchema.parse(['a', 'b', 2]);
  /// print(list); // Output: ['a', 'b', 2]
  ///
  /// final listEmpty = listSchema.parse([]);
  /// print(listEmpty); // Output: null
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

  /// min validation
  ///
  /// Example:
  /// final listSchema = z.list(z.string()).min(2);
  /// final list = listSchema.parse(['a', 'b', '2']);
  /// print(list); // Output: ['a', 'b', '2']
  ///
  /// final listEmpty = listSchema.parse([]);
  /// print(listEmpty); // Output: null
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

  /// max validation
  ///
  /// Example:
  /// final listSchema = z.list(z.string()).max(2);
  /// final list = listSchema.parse(['a', 'b', '2']);
  /// print(list); // Output: null
  ///
  /// final listEmpty = listSchema.parse([]);
  /// print(listEmpty); // Output: []
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

  /// length validation
  ///
  /// Example:
  /// final listSchema = z.list(z.string()).length(2);
  /// final list = listSchema.parse(['a', 'b', '2']);
  /// print(list); // Output: null
  ///
  /// final listEmpty = listSchema.parse([]);
  /// print(listEmpty); // Output: null
  ///
  /// final listEmpty = listSchema.parse(['a', 'b']);
  /// print(listEmpty); // Output: ['a', 'b']
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
