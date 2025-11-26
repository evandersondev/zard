import 'package:zard/zard.dart';

abstract interface class ZDefault<T> extends Schema<T> {
  final T defaultValue;
  final Schema<T> schema;

  ZDefault(this.schema, this.defaultValue) {
    nullish();

    addTransform((value) {
      if (value == null) {
        return defaultValue;
      }
      return value;
    });
  }

  @override
  T parse(dynamic value, {String path = ''}) {
    final valueToParse = value ?? defaultValue;
    return schema.parse(valueToParse, path: path);
  }
}

class ZDefaultImpl<T> extends ZDefault<T> {
  ZDefaultImpl(super.schema, super.defaultValue);
}
