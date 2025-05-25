import 'schema.dart';

class LazySchema<T> extends Schema<T> {
  final Schema<T> Function() schemaThunk;

  LazySchema(this.schemaThunk);

  @override
  T parse(dynamic value) {
    // Get the actual schema when needed.
    final actualSchema = schemaThunk();
    return actualSchema.parse(value);
  }

  @override
  Future<T?> parseAsync(dynamic value) async {
    final actualSchema = schemaThunk();
    return await actualSchema.parseAsync(value);
  }
}
