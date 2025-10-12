class ZardIssue {
  final String message;
  final String type;
  final String? path;
  final dynamic value;

  // Campos adicionais para customização de erros
  final dynamic input;
  final Map<String, dynamic>? metadata;

  ZardIssue({
    required this.message,
    required this.type,
    required this.value,
    this.path,
    this.input,
    this.metadata,
  });

  @override
  String toString() => 'ZardIssue(message: $message, type: $type, value: $value, path: $path)';

  /// Cria uma cópia do issue com novos valores
  ZardIssue copyWith({
    String? message,
    String? type,
    String? path,
    dynamic value,
    dynamic input,
    Map<String, dynamic>? metadata,
  }) {
    return ZardIssue(
      message: message ?? this.message,
      type: type ?? this.type,
      path: path ?? this.path,
      value: value ?? this.value,
      input: input ?? this.input,
      metadata: metadata ?? this.metadata,
    );
  }
}
