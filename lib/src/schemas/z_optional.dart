import 'schema.dart';

class ZOptional<T> extends Schema<T?> {
  final Schema inner;

  ZOptional(this.inner);

  @override
  bool get isOptional => true;

  @override
  T? parse(dynamic value, {String path = ''}) {
    if (value == null) return null;
    return inner.parse(value, path: path);
  }
}
