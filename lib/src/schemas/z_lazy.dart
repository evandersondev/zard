import 'schema.dart';

class LazySchema<T> extends Schema<T> {
  final Schema<T> Function() schemaThunk;

  LazySchema(this.schemaThunk);

  @override
  T parse(dynamic value, {String? path}) {
    // Get the actual schema when needed.
    final actualSchema = schemaThunk();
    return actualSchema.parse(value);
  }

  @override
  Future<T?> parseAsync(dynamic value, {String? path}) async {
    final actualSchema = schemaThunk();
    return await actualSchema.parseAsync(value);
  }
}
