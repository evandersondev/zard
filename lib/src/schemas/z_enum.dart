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

  /// Extract value from enum transform.
  /// Example:
  /// ```dart
  /// final value = z.enum(['a', 'b', 'c']).extract(['a', 'b']);
  /// print(value); // Prints: ['a', 'b']
  /// ```
  ZEnum extract(List<String> list) {
    addTransform((value) {
      return value.where((e) => list.contains(e)).toList();
    });
    return this;
  }

  /// Exclude value from enum transform.
  /// Example:
  /// ```dart
  /// final value = z.enum(['a', 'b', 'c']).exclude(['a', 'b']);
  /// print(value); // Prints: ['c']
  /// ```
  ZEnum exclude(List<String> list) {
    addTransform((value) {
      return value.where((e) => !list.contains(e)).toList();
    });
    return this;
  }

  @override
  List<String> parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! List<String>) {
      addError(
        ZardError(
          message: 'Expected a list of strings',
          type: 'type_error',
          value: value,
        ),
      );
      throw Exception(
        'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}',
      );
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
      throw Exception(
        'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}',
      );
    }

    for (final transform in getTransforms()) {
      value = transform(value);
    }

    return value;
  }

  @override
  String toString() {
    return 'ZEnum($_allowedValues)';
  }
}
