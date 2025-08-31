import '../schemas/schema.dart';
import '../types/zard_error.dart';

abstract class CustomModel {
  // Factory method to create an instance from validated JSON.
  factory CustomModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}

/// ZardType is a custom Schema that validates a Map and transforms it into a model instance T.
class ZardType<T> extends Schema<T> {
  // Function that transforms the validated Map into a model instance.
  final T Function(Map<String, dynamic> json) fromMap;

  // Internal schema to validate the Map (can be a ZMap out of the box).
  final Schema<Map<String, dynamic>> mapSchema;

  ZardType({
    required this.fromMap,
    required this.mapSchema,
  });

  @override
  T parse(dynamic value, {String? path}) {
    // First validates the Map with the Map schema.
    final validatedMap = mapSchema.parse(value);

    // Converts the validated Map to the model instance
    final result = fromMap(validatedMap);

    // Executes inherited validators from the base Schema (including refine)
    for (final validator in getValidators()) {
      final error = validator(result);
      if (error != null) {
        addError(error);
      }
    }

    // Executes transformations
    T transformedResult = result;
    for (final transform in getTransforms()) {
      transformedResult = transform(transformedResult);
    }

    // If there are errors, throws exception
    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return transformedResult;
  }
}
