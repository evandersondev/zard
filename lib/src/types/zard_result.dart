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
}
