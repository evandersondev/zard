import '../schemas/schema.dart';
import '../types/zard_error.dart';

abstract class CustomModel {
  factory CustomModel.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
}

/// Validates a Map using [mapSchema] then transforms it into a model instance
/// of type [T] using [fromMap].
class ZardType<T> extends Schema<T> {
  final T Function(Map<String, dynamic> json) fromMap;
  final Schema<Map<String, dynamic>> mapSchema;

  ZardType({
    required this.fromMap,
    required this.mapSchema,
  });

  @override
  T parse(dynamic value, {String path = ''}) {
    clearErrors();
    final sink = issuesInternal;

    // Validate the Map first; errors from mapSchema propagate via ZardError.
    final Map<String, dynamic> validatedMap =
        mapSchema.parse(value, path: path);

    // Convert the validated Map to the model instance.
    final T result = fromMap(validatedMap);

    // Run any validators/refine calls attached to this ZardType.
    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](result);
      if (error != null) {
        sink.add(error);
      }
    }

    if (sink.isNotEmpty) {
      throw ZardError(sink);
    }

    // Apply transforms.
    T transformed = result;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      transformed = transforms[i](transformed);
    }

    return transformed;
  }

  @override
  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    clearErrors();
    final sink = issuesInternal;

    final Map<String, dynamic> validatedMap =
        await mapSchema.parseAsync(value, path: path);
    final T result = fromMap(validatedMap);

    final validators = validatorsInternal;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](result);
      if (error != null) {
        sink.add(error);
      }
    }

    if (sink.isNotEmpty) {
      throw ZardError(sink);
    }

    T transformed = result;
    final transforms = transformsInternal;
    for (var i = 0; i < transforms.length; i++) {
      transformed = transforms[i](transformed);
    }

    return transformed;
  }
}
