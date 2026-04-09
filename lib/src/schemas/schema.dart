import 'package:zard/src/types/parse_context.dart';
import 'package:zard/src/types/zard_error.dart';

import '../types/zard_issue.dart';
import '../types/zard_result.dart';
import 'schemas.dart';
import 'transformed_schema.dart';

typedef Validator<T> = ZardIssue? Function(T value);
typedef Transformer<T> = T Function(T value);

abstract class Schema<T> {
  final List<Validator<T>> _validators = [];
  final List<Transformer<T>> _transforms = [];
  bool _isOptional = false;
  bool _nullable = false;

  // ParseContext for the current parse invocation.
  // Replaced on every clearErrors() call (i.e., at the start of each parse()).
  // Subclasses and containers read/write through addError() / issues.
  ParseContext _ctx = ParseContext();

  bool get isOptional => _isOptional;
  bool get isNullable => _nullable;

  // ----- Backward-compatible accessors backed by the current context -----

  /// The issues accumulated during the most-recent parse call.
  /// Mutable so containers (ZMap, ZList) can do `issues.addAll(...)`.
  List<ZardIssue> get issues => _ctx.issues;

  void addError(ZardIssue error) => _ctx.addIssue(error);

  /// Resets the current parse context.  Called at the start of every parse().
  void clearErrors() => _ctx = ParseContext();

  List<ZardIssue> getErrors() => List.unmodifiable(issues);

  // -----------------------------------------------------------------------

  void addValidator(Validator<T> validator) {
    _validators.add(validator);
  }

  void addTransform(Transformer<T> transform) {
    _transforms.add(transform);
  }

  List<Validator<T>> getValidators() => List.unmodifiable(_validators);
  List<Transformer<T>> getTransforms() => List.unmodifiable(_transforms);

  TransformedSchema<T, R> transform<R>(R Function(T value) transformer) {
    return TransformedSchemaImpl<T, R>(this, transformer);
  }

  TransformedSchema<T, R> transformTyped<R>(R Function(T value) transformer) {
    return TransformedSchemaImpl<T, R>(this, transformer);
  }

  Schema<T> optional() {
    _isOptional = true;
    return this;
  }

  Schema<T> nullable() {
    _nullable = true;
    return this;
  }

  Schema<T> nullish() {
    _nullable = true;
    _isOptional = true;
    return this;
  }

  /// Marks this schema as required (removes optional flag).
  Schema<T> markRequired() {
    _isOptional = false;
    return this;
  }

  /// A schema to define a default value for a field.
  /// ```dart
  /// final schema = z.string().$default('Hello World');
  /// final result = schema.parse(null);
  /// print(result); // "Hello World"
  /// ```
  Schema $default(T defaultValue) {
    return ZDefaultImpl(this, defaultValue);
  }

  ZList list({String? message}) {
    return ZListImpl(this, message: message);
  }

  Schema<T> refine(bool Function(T value) predicate,
      {String? message, String? path}) {
    addValidator((T value) {
      if (!predicate(value)) {
        return ZardIssue(
          message: message ?? 'Refinement failed',
          type: 'refine_error',
          value: value,
          path: path,
        );
      }
      return null;
    });
    return this;
  }

  // -----------------------------------------------------------------------
  // Core parse methods
  // -----------------------------------------------------------------------

  T parse(dynamic value, {String path = ''}) {
    clearErrors();

    if (value == null) {
      addError(ZardIssue(
        message: 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(List.of(issues));
    }

    // Safe type check — prevents a raw `value as T` crash before validation.
    if (value is! T) {
      addError(ZardIssue(
        message: 'Invalid type: expected $T, got ${value.runtimeType}',
        type: 'type_error',
        value: value,
        path: path.isEmpty ? null : path,
      ));
      throw ZardError(List.of(issues));
    }

    T result = value; // Safe: passed is! check above

    for (final validator in _validators) {
      final error = validator(result);
      if (error != null) {
        addError(ZardIssue(
          message: error.message,
          type: error.type,
          value: value,
          path: path.isEmpty ? null : path,
        ));
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(List.of(issues));
    }

    for (final transform in _transforms) {
      result = transform(result);
    }

    return result;
  }

  ZardResult<T> safeParse(dynamic value, {String path = ''}) {
    try {
      final parsed = parse(value, path: path);
      return ZardResult<T>(success: true, data: parsed);
    } on ZardError catch (e) {
      return ZardResult<T>(success: false, error: e);
    } catch (_) {
      return ZardResult<T>(success: false, error: ZardError(List.of(issues)));
    }
  }

  Future<T> parseAsync(dynamic value, {String path = ''}) async {
    try {
      final resolvedValue = value is Future ? await value : value;
      return parse(resolvedValue, path: path);
    } on ZardError catch (e) {
      return Future.error(e);
    }
  }

  Future<ZardResult<T>> safeParseAsync(dynamic value,
      {String path = ''}) async {
    try {
      final parsed = await parseAsync(value, path: path);
      return ZardResult<T>(success: true, data: parsed);
    } on ZardError catch (e) {
      return ZardResult<T>(success: false, error: e);
    }
  }
}
