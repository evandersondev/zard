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

  // O método .optional() não altera o comportamento de parse() diretamente,
  // pois a omissão (campo não fornecido) deve ser tratada por schemas contêiner, como ZMap.
  Schema<T> optional() {
    _isOptional = true;
    return this;
  }

  // O método .nullable() permite que valores null sejam aceitos.
  Schema<T> nullable() {
    _nullable = true;
    return this;
  }

  void addTransform(Transformer<T> transform) {
    _transforms.add(transform);
  }

  T? parse(dynamic value) {
    clearErrors();

    if (value == null) {
      if (_nullable) {
        return null;
      } else {
        addError(ZardError(
          message: 'Value is required and cannot be null',
          type: 'required_error',
          value: value,
        ));
        throw Exception(
            'Validation failed with errors: ${errors.map((e) => e.toString()).toList()}');
      }
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
