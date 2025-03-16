import '../types/zart_error.dart';
import 'schema.dart';

class ZList extends Schema<List<dynamic>> {
  final Schema _itemSchema;

  ZList(this._itemSchema);

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

    if (errors.isNotEmpty) {
      return null;
    }

    return result;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value) {
    final parsed = parse(value);
    if (parsed == null) {
      return {'success': false, 'errors': getErrors()};
    }
    return {'success': true, 'data': parsed};
  }
}
