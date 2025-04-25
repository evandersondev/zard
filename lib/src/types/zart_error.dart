import 'zard_issue.dart';

class ZardError implements Exception {
  final List<ZardIssue> issues;

  ZardError(this.issues);

  String get messages => issues.map((issue) => '${issue.message}').join(', ');

  List<String> format() {
    return issues.map((issue) => issue.message).toList();
  }

  @override
  String toString() {
    return 'ZardError: ${issues.map((issue) => issue.toString()).join(', ')}';
  }
}
