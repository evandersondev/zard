import '../types/zart_error.dart';

typedef Validator<T> = ZardError? Function(T value);
typedef Transformer<T> = T Function(T value);

abstract class Schema<T> {
  final List<Validator<T>> _validators = [];
  final List<T Function(T)> _transforms = [];
  bool _isOptional = false;
  bool _nullable = false;
  final List<ZardError> errors = [];

  bool get isOptional => _isOptional;
  bool get isNullable => _nullable;

  /// Adds a validator function.
  void addValidator(Validator<T> validator) {
    _validators.add(validator);
  }

  Schema<T> transform(Transformer<T> transformer) {
    addTransform(transformer);
    return this;
  }

  /// Optional field. If the field is optional, it will not be validated.
  /// Example:
  /// ```dart
  /// final schema = z.string().optional();
  /// schema.parse('hello'); // returns 'hello'
  /// schema.parse(null); // returns null
  /// ```
  Schema<T> optional() {
    _isOptional = true;
    return this;
  }

  /// Nullable field. If the field is nullable, it will not be validated.
  /// Example:
  /// ```dart
  /// final schema = z.string().nullable();
  /// schema.parse('hello'); // returns 'hello'
  /// schema.parse(null); // returns null
  /// ```
  Schema<T> nullable() {
    _nullable = true;
    return this;
  }

  /// Adds a transform function that will modify the return value
  /// after all validations pass.
  void addTransform(T Function(T value) transform) {
    _transforms.add(transform);
  }

  /// Executes all validations and then applies transformations
  /// to the value if it is valid. Throws an Exception if any
  /// validation fails.
  T? parse(dynamic value) {
    clearErrors();

    if ((_isOptional || _nullable) && value == null) {
      return null;
    }

    T result = value as T;
    for (final validator in _validators) {
      final error = validator(result);
      if (error != null) {
        addError(ZardError(
          message: error.message,
          type: error.type,
          value: value,
        ));
      }
    }
    for (final transform in _transforms) {
      result = transform(result);
    }

    if (errors.isNotEmpty) {
      return null;
    }

    return result;
  }

  void addError(ZardError error) {
    errors.add(error);
  }

  void clearErrors() {
    errors.clear();
  }

  List<Validator<T?>> getValidators() {
    return List.unmodifiable(_validators);
  }

  List<ZardError> getErrors() {
    return List.unmodifiable(errors);
  }

  List<Transformer<T>> getTransforms() {
    return List.unmodifiable(_transforms);
  }

  /// Returns a map indicating if the value is valid and, if so,
  /// the transformed result. Otherwise, returns the error message.
  Map<String, dynamic> safeParse(dynamic value) {
    try {
      final parsed = parse(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
