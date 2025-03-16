import '../types/zart_error.dart';
import 'schema.dart';

class ZEnum extends Schema<List<String>> {
  final List<String> _allowedValues;

  ZEnum(this._allowedValues, {String? message}) {
    addValidator((List<String>? value) {
      if (value == null) {
        return ZardError(
          message: message ?? 'Expected a list of strings',
          type: 'type_error',
          value: value,
        );
      }

      for (var element in value) {
        if (!_allowedValues.contains(element)) {
          return ZardError(
            message: message ?? 'Value must be one of $_allowedValues',
            type: 'enum_error',
            value: element,
          );
        }
      }
      return null;
    });
  }

  /// extract value from enum transform
  ///
  /// example:
  /// final extract = z.enum(['a', 'b', 'c']);
  /// final value = extract.extract(['a']);
  /// print(value); // ['a']
  ZEnum extract(List<String> list) {
    // extract all values from enum
    addTransform((value) {
      return list.where((e) => value.contains(e)).toList();
    });
    return this;
  }

  /// exclude value from enum transform
  ///
  /// example:
  /// final exclude = z.enum(['a', 'b', 'c']);
  /// final value = exclude.exclude(['a']);
  /// print(value); // ['b', 'c']
  ZEnum exclude(List<String> list) {
    addTransform((value) {
      return value.where((e) => !list.contains(e)).toList();
    });
    return this;
  }

  @override
  List<String>? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! List<String>) {
      addError(
        ZardError(
          message: 'Expected a list of strings',
          type: 'type_error',
          value: value,
        ),
      );
      return null;
    }

    for (final element in value) {
      if (!_allowedValues.contains(element)) {
        addError(
          ZardError(
            message: 'Value must be one of $_allowedValues',
            type: 'enum_error',
            value: element,
          ),
        );
      }
    }

    if (errors.isNotEmpty) {
      return null;
    }

    for (final transform in getTransforms()) {
      value = transform(value);
    }

    return value;
  }

  // toString()
  @override
  String toString() {
    return 'ZEnum($_allowedValues)';
  }
}
