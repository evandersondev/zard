import 'dart:async';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

/// A schema produced by [Schema.refineAsync]. Wraps an [inner] schema and, on
/// the async parse path, runs an asynchronous [predicate] against the parsed
/// value.
///
/// Because the predicate may be asynchronous, it can only be honored by
/// [parseAsync] / [safeParseAsync]. Calling the synchronous [parse] on a schema
/// that carries an async refinement throws a [StateError] instructing the user
/// to use `parseAsync`.
///
/// Example:
/// ```dart
/// final schema = z.string().refineAsync(
///   (v) async => await isUniqueInDb(v),
///   message: 'Value already taken',
/// );
/// await schema.parseAsync('foo');
/// ```
abstract interface class AsyncRefinedSchema<T> extends Schema<T> {
  final Schema<T> inner;
  final FutureOr<bool> Function(T value) predicate;
  final String message;
  final String? refinePath;

  AsyncRefinedSchema(
    this.inner,
    this.predicate, {
    required this.message,
    this.refinePath,
  });

  @override
  bool get hasAsyncRefinements => true;

  Never _throwSyncError() {
    throw StateError(
      'This schema has async refinements (refineAsync) and cannot be parsed '
      'synchronously. Use parseAsync() / safeParseAsync() instead.',
    );
  }

  @override
  T parse(dynamic value, {String path = ''}) => _throwSyncError();

  @override
  T? parseInto(dynamic value, String path, List<ZardIssue> sink) =>
      _throwSyncError();

  @override
  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    final T result = await inner.parseAsync(value, path: path);

    final ok = await predicate(result);
    if (!ok) {
      throw ZardError([
        ZardIssue(
          message: message,
          type: 'refine_error',
          value: result,
          path: refinePath ?? (path.isEmpty ? null : path),
        )
      ]);
    }

    return result;
  }

  @override
  String toString() => 'AsyncRefinedSchema($inner)';
}

class AsyncRefinedSchemaImpl<T> extends AsyncRefinedSchema<T> {
  AsyncRefinedSchemaImpl(
    super.inner,
    super.predicate, {
    required super.message,
    super.refinePath,
  });
}
