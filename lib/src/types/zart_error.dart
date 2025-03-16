class ZardError {
  final String message;
  final String type;
  final dynamic value;

  ZardError({
    required this.message,
    required this.type,
    required this.value,
  });

  @override
  String toString() {
    return '{message: $message, type: $type, value: $value}';
  }
}
