import 'zard_issue.dart';

/// Holds all validation issues for a single parse invocation.
///
/// Created fresh at the start of each [Schema.parse] call, so schemas
/// are stateless between invocations. Each schema stores a reference to
/// the *current* context via [Schema._ctx].
class ParseContext {
  final List<ZardIssue> issues = [];

  void addIssue(ZardIssue issue) => issues.add(issue);
  void addAll(List<ZardIssue> other) => issues.addAll(other);
  bool get hasErrors => issues.isNotEmpty;
}

/// Returns `'$base.$key'` when [base] is non-empty, otherwise just `key`.
/// Use this for building field paths in nested schemas.
String joinPath(String base, String key) =>
    base.isEmpty ? key : '$base.$key';
