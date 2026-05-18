import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class TransformedSchema<T, R> extends Schema<R> {
  final Schema<T> inner;
  final R Function(T value) transformer;

  TransformedSchema(this.inner, this.transformer);

  @override
  R parse(dynamic value, {String path = ''}) {
    // Parse the inner schema first; errors propagate via ZardError.
    final T originalResult = inner.parse(value, path: path);
    return transformer(originalResult);
  }

  @override
  Future<R> parseAsync(dynamic value, {String path = ''}) async {
    final T originalResult = await inner.parseAsync(value, path: path);
    return transformer(originalResult);
  }

  @override
  R? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final beforeLen = sink.length;
    final inner_ = inner.parseInto(value, path, sink);
    if (sink.length != beforeLen) return null;
    return transformer(inner_ as T);
  }
}

class TransformedSchemaImpl<T, R> extends TransformedSchema<T, R> {
  TransformedSchemaImpl(super.inner, super.transformer);
}
