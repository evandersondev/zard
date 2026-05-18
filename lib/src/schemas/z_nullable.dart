import '../types/zard_issue.dart';
import 'schema.dart';

class ZNullable<T> extends Schema<T?> {
  final Schema inner;

  ZNullable(this.inner);

  @override
  bool get isNullable => true;

  // Schema<T> unwrap() => inner;

  @override
  T? parse(dynamic value, {String path = ''}) {
    if (value == null) return null;
    return inner.parse(value, path: path);
  }

  @override
  T? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    if (value == null) return null;
    return inner.parseInto(value, path, sink) as T?;
  }
}
