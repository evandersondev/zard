import '../types/zard_issue.dart';
import 'schema.dart';

/// A schema produced by [Schema.pipe]. Feeds the parsed/transformed output of
/// [source] into [next], composing two schemas linearly.
///
/// Example:
/// ```dart
/// final schema = z.string().transform(int.parse).pipe(z.int().min(0));
/// schema.parse('42'); // 42
/// ```
///
/// Issues from either stage propagate with their original paths, matching the
/// no-throw `parseInto` hot-path contract used by container schemas.
abstract interface class PipedSchema<T, R> extends Schema<R> {
  final Schema<T> source;
  final Schema<R> next;

  PipedSchema(this.source, this.next);

  @override
  R parse(dynamic value, {String path = ''}) {
    // Source errors propagate via ZardError; its output feeds `next`.
    final T sourceResult = source.parse(value, path: path);
    return next.parse(sourceResult, path: path);
  }

  @override
  R? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final beforeSource = sink.length;
    final sourceResult = source.parseInto(value, path, sink);
    if (sink.length != beforeSource) return null;
    return next.parseInto(sourceResult, path, sink);
  }

  @override
  Future<R> parseAsync(dynamic value, {String path = ''}) async {
    final T sourceResult = await source.parseAsync(value, path: path);
    return next.parseAsync(sourceResult, path: path);
  }

  @override
  String toString() => 'PipedSchema($source -> $next)';
}

class PipedSchemaImpl<T, R> extends PipedSchema<T, R> {
  PipedSchemaImpl(super.source, super.next);
}
