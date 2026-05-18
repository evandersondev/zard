import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

class ZUnion extends Schema<dynamic> {
  final List<Schema> schemas;

  ZUnion(this.schemas);

  @override
  dynamic parse(dynamic value, {String path = ''}) {
    final pathOrNull = path.isEmpty ? null : path;
    final unionErrors = <ZardIssue>[];

    for (var i = 0; i < schemas.length; i++) {
      final before = unionErrors.length;
      final r = schemas[i].parseInto(value, path, unionErrors);
      if (unionErrors.length == before) {
        return r;
      }
    }

    unionErrors.add(ZardIssue(
      message: 'Value does not match any union type',
      type: 'union_error',
      value: value,
      path: pathOrNull,
    ));

    throw ZardError(unionErrors);
  }

  @override
  Object? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final pathOrNull = path.isEmpty ? null : path;
    final localErrors = <ZardIssue>[];

    for (var i = 0; i < schemas.length; i++) {
      final before = localErrors.length;
      final r = schemas[i].parseInto(value, path, localErrors);
      if (localErrors.length == before) {
        return r;
      }
    }

    sink.addAll(localErrors);
    sink.add(ZardIssue(
      message: 'Value does not match any union type',
      type: 'union_error',
      value: value,
      path: pathOrNull,
    ));
    return null;
  }

  @override
  Future<dynamic> parseAsync(dynamic value, {String path = ''}) async {
    for (final schema in schemas) {
      final result = await schema.safeParseAsync(value, path: path);

      if (result.success) {
        return result.data;
      }
    }

    throw ZardError([
      ZardIssue(
        message: 'Value does not match any union type',
        type: 'union_error',
        value: value,
        path: path.isEmpty ? null : path,
      )
    ]);
  }
}
