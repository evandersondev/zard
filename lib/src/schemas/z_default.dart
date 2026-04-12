import '../types/zard_error.dart';
import 'schema.dart';

class ZDefault<T> extends Schema<T> {
  final Schema<T> inner;
  final T defaultValue;

  ZDefault(this.inner, this.defaultValue);

  bool get hasDefault => true;

  @override
  T parse(dynamic value, {String path = ''}) {
    clearErrors();

    // 🔥 AQUI ESTÁ A MÁGICA
    if (value == null) {
      return defaultValue;
    }

    try {
      return inner.parse(value, path: path);
    } on ZardError catch (e) {
      issues.addAll(e.issues);
      throw ZardError(List.of(issues));
    }
  }

  @override
  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    if (value == null) return defaultValue;
    return await inner.parseAsync(value, path: path);
  }
}
