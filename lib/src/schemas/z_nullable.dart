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
}
