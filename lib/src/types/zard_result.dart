import 'zard_error.dart';

class ZardResult<T> {
  final bool success;
  final T? data;
  final ZardError? error;

  ZardResult({
    required this.success,
    this.data,
    this.error,
  });

  /// Returns [data] or throws the [ZardError] if parsing failed.
  T unwrap() {
    if (!success) throw error ?? ZardError.empty();
    return data as T;
  }

  /// Returns [data] on success, or `null` on failure — never throws.
  T? unwrapOrNull() => success ? data : null;

  /// Pattern-matches on success/failure, similar to Zod's `.safeParse()` handling.
  ///
  /// ```dart
  /// result.when(
  ///   success: (value) => print(value),
  ///   error: (err) => print(err.messages),
  /// );
  /// ```
  R when<R>({
    required R Function(T data) success,
    required R Function(ZardError error) error,
  }) {
    if (this.success) return success(data as T);
    return error(this.error ?? ZardError.empty());
  }
}
