import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

class ZUnion extends Schema<dynamic> {
  final List<Schema> schemas;

  ZUnion(this.schemas);

  @override
  dynamic parse(dynamic value, {String path = ''}) {
    clearErrors();

    final List<ZardIssue> unionErrors = [];

    for (final schema in schemas) {
      final result = schema.safeParse(value, path: path);

      if (result.success) {
        return result.data;
      } else {
        unionErrors.addAll(result.error?.issues ?? []);
      }
    }

    addError(ZardIssue(
      message: 'Value does not match any union type',
      type: 'union_error',
      value: value,
      path: path.isEmpty ? null : path,
    ));

    throw ZardError(List.of(issues + unionErrors));
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
