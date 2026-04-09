import 'package:zard/zard.dart';

abstract interface class ZDefault<T> extends Schema<T> {
  final T defaultValue;
  final Schema<T> schema;

  ZDefault(this.schema, this.defaultValue) {
    nullish();
  }

  @override
  T parse(dynamic value, {String path = ''}) {
    // If value is null or missing, use the default.
    final valueToParse = value ?? defaultValue;
    return schema.parse(valueToParse, path: path);
  }

  @override
  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    final valueToParse = value ?? defaultValue;
    return schema.parseAsync(valueToParse, path: path);
  }
}

class ZDefaultImpl<T> extends ZDefault<T> {
  ZDefaultImpl(super.schema, super.defaultValue);
}
