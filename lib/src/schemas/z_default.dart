import '../types/zard_issue.dart';
import 'schema.dart';

class ZDefault<T> extends Schema<T> {
  final Schema<T> inner;
  final T defaultValue;

  ZDefault(this.inner, this.defaultValue);

  bool get hasDefault => true;

  @override
  T parse(dynamic value, {String path = ''}) {
    // Short-circuit on null — no error path to set up.
    if (value == null) {
      return defaultValue;
    }
    // The inner parse already throws ZardError with the right issues attached;
    // let it propagate untouched (one allocation total instead of three).
    return inner.parse(value, path: path);
  }

  @override
  T? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    if (value == null) return defaultValue;
    return inner.parseInto(value, path, sink);
  }

  @override
  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    if (value == null) return defaultValue;
    return await inner.parseAsync(value, path: path);
  }
}
