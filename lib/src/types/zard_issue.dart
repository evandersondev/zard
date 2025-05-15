class ZardIssue {
  final String message;
  final String type;
  final String? path;
  final dynamic value;

  ZardIssue({
    required this.message,
    required this.type,
    required this.value,
    this.path,
  });

  @override
  String toString() =>
      'ZardIssue(message: $message, type: $type, value: $value, path: $path)';
}
