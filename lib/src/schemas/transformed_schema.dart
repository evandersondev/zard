import 'schema.dart';

class TransformedSchema<T, R> extends Schema<R> {
  final Schema<T> inner;
  final R Function(T value) transformer;

  TransformedSchema(this.inner, this.transformer);

  @override
  R parse(dynamic value, {String? path}) {
    // Verifica se o valor retornado pelo inner.parse é nulo e lança um erro customizado, se necessário.
    final T? originalResult = inner.parse(value);
    if (originalResult == null) {
      throw Exception("Transformation error: inner.parse returned null");
    }
    return transformer(originalResult);
  }

  @override
  Future<R?> parseAsync(dynamic value, {String? path}) async {
    final T? originalResult = await inner.parseAsync(value);
    if (originalResult == null) {
      throw Exception("Transformation error: inner.parseAsync returned null");
    }
    return transformer(originalResult);
  }
}
