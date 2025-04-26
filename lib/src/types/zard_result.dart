import 'zart_error.dart';

class ZardResult {
  final bool success;
  final dynamic data;
  final ZardError? error;

  ZardResult({
    required this.success,
    this.data,
    this.error,
  });
}
