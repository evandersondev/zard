import 'package:zard/src/types/zart_error.dart';

typedef Validator<T> = ZardError? Function(T value);
typedef Transformer<T> = T Function(T value);

abstract class Schema<T> {
  final List<Validator<T>> _validators = [];
  final List<Transformer<T>> _transforms = [];
  bool _isOptional = false;
  bool _nullable = false;
  final List<ZardError> errors = [];

  bool get isOptional => _isOptional;
  bool get isNullable => _nullable;

  void addValidator(Validator<T> validator) {
    _validators.add(validator);
  }

  Schema<T> transform(Transformer<T> transformer) {
    addTransform(transformer);
    return this;
  }

  Schema<T> optional() {
    _isOptional = true;
    return this;
  }

  Schema<T> nullable() {
    _nullable = true;
    return this;
  }

  void addTransform(Transformer<T> transform) {
    _transforms.add(transform);
  }

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
      throw Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
    }

    return result;
  }

  void addError(ZardError error) {
    errors.add(error);
  }

  void clearErrors() {
    errors.clear();
  }

  List<Validator<T>> getValidators() {
    return List.unmodifiable(_validators);
  }

  List<ZardError> getErrors() {
    return List.unmodifiable(errors);
  }

  List<Transformer<T>> getTransforms() {
    return List.unmodifiable(_transforms);
  }

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

  // Asynchronous version of parse.
  Future<T?> parseAsync(dynamic value) async {
    clearErrors();
    try {
      // Se o valor for um Future, aguarda a sua resolução.
      final resolvedValue = value is Future ? await value : value;
      final result = parse(resolvedValue);
      return result;
    } catch (e) {
      return Future.error(Exception(
          'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}'));
    }
  }

  // Asynchronous version of safeParse.
  Future<Map<String, dynamic>> safeParseAsync(dynamic value) async {
    try {
      final parsed = await parseAsync(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {
        'success': false,
        'errors': errors.map((e) => e.toString()).toList()
      };
    }
  }

  Schema<T> refine(bool Function(T value) predicate, {String? message}) {
    addValidator((T value) {
      if (!predicate(value)) {
        return ZardError(
          message: message ?? "Refinement failed",
          type: "refine_error",
          value: value,
        );
      }
      return null;
    });
    return this;
  }
}
