class ZardIssue {
  final String message;
  final String type;
  final dynamic value;

  ZardIssue({
    required this.message,
    required this.type,
    required this.value,
  });

  @override
  String toString() =>
      'ZardIssue(message: $message, type: $type, value: $value)';
}
