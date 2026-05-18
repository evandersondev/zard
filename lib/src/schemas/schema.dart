import 'package:zard/src/types/parse_context.dart';
import 'package:zard/src/types/zard_error.dart';

import '../types/zard_issue.dart';
import '../types/zard_result.dart';
import 'schemas.dart';
import 'transformed_schema.dart';
import 'z_nullable.dart';
import 'z_optional.dart';

typedef Validator<T> = ZardIssue? Function(T value);
typedef Transformer<T> = T Function(T value);

abstract class Schema<T> {
  final List<Validator<T>> _validators = [];
  final List<Transformer<T>> _transforms = [];

  // ParseContext for the current parse invocation.
  // The context's issues list is cleared in-place at the start of each parse()
  // call (see [clearErrors]) — no allocation on the success path.
  final ParseContext _ctx = ParseContext();

  // ✅ NOVO (dinâmico)
  bool get isOptional => this is ZOptional;
  bool get isNullable => this is ZNullable;

  /// 🔥 MUITO IMPORTANTE
  bool get isOptionalLike => this is ZOptional || this is ZDefault;

  // ----- Backward-compatible accessors backed by the current context -----

  /// The issues accumulated during the most-recent parse call.
  /// Mutable so containers (ZMap, ZList) can do `issues.addAll(...)`.
  List<ZardIssue> get issues => _ctx.issues;

  void addError(ZardIssue error) => _ctx.addIssue(error);

  /// Resets the current parse context. Called at the start of every parse().
  /// Uses [List.clear] in-place to avoid allocating a fresh context per call.
  void clearErrors() => _ctx.issues.clear();

  List<ZardIssue> getErrors() => List.unmodifiable(issues);

  // -----------------------------------------------------------------------

  void addValidator(Validator<T> validator) {
    _validators.add(validator);
  }

  void addTransform(Transformer<T> transform) {
    _transforms.add(transform);
  }

  /// Public, backward-compatible accessor — returns an unmodifiable view.
  /// Internal hot paths should iterate [validatorsInternal] / [transformsInternal] directly.
  List<Validator<T>> getValidators() => List.unmodifiable(_validators);
  List<Transformer<T>> getTransforms() => List.unmodifiable(_transforms);

  /// Non-allocating raw lists. Library-internal use only — never expose
  /// these to consumers because they bypass the unmodifiable contract.
  /// Used by specialized schema implementations (ZInt, ZDouble, etc.) to
  /// avoid creating an [List.unmodifiable] wrapper per parse() call.
  List<Validator<T>> get validatorsInternal => _validators;
  List<Transformer<T>> get transformsInternal => _transforms;

  /// Direct access to the parse context's issues list — internal use only.
  List<ZardIssue> get issuesInternal => _ctx.issues;

  TransformedSchema<T, R> transform<R>(R Function(T value) transformer) {
    return TransformedSchemaImpl<T, R>(this, transformer);
  }

  TransformedSchema<T, R> transformTyped<R>(R Function(T value) transformer) {
    return TransformedSchemaImpl<T, R>(this, transformer);
  }

  Schema<T?> optional() {
    return ZOptional<T>(this);
  }

  Schema<T?> nullable() {
    return ZNullable<T>(this);
  }

  Schema<T?> nullish() {
    return ZNullable(ZOptional<T>(this));
  }

  /// Marks this schema as required (removes optional flag).
  Schema markRequired() {
    if (this is ZOptional) {
      return (this as ZOptional).inner.markRequired();
    }

    if (this is ZNullable) {
      return ZNullable((this as ZNullable).inner.markRequired());
    }

    return this;
  }

  /// A schema to define a default value for a field.
  /// ```dart
  /// final schema = z.string().$default('Hello World');
  /// final result = schema.parse(null);
  /// print(result); // "Hello World"
  /// ```
  Schema<T> $default(T defaultValue) {
    return ZDefault<T>(this, defaultValue);
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
  // Internal no-throw parse path
  // -----------------------------------------------------------------------

  /// Internal entry point used by container schemas (ZMap, ZList, ZUnion,
  /// ZInterface, etc.) to avoid the per-field/per-item try/catch overhead
  /// of public [parse]. On success returns the parsed value and leaves
  /// [sink] unchanged. On failure appends at least one issue to [sink]
  /// (callers determine success by comparing `sink.length` before/after).
  ///
  /// The default implementation simply wraps [parse]; specialized schemas
  /// override this to skip exceptions entirely on the failure path.
  T? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    try {
      return parse(value, path: path);
    } on ZardError catch (e) {
      sink.addAll(e.issues);
      return null;
    }
  }

  // -----------------------------------------------------------------------
  // Core parse methods
  // -----------------------------------------------------------------------

  T parse(dynamic value, {String path = ''}) {
    clearErrors();
    final pathOrNull = path.isEmpty ? null : path;

    if (value == null) {
      _ctx.issues.add(ZardIssue(
        message: 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(_ctx.issues);
    }

    // Safe type check — prevents a raw `value as T` crash before validation.
    if (value is! T) {
      _ctx.issues.add(ZardIssue(
        message: 'Invalid type: expected $T, got ${value.runtimeType}',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      throw ZardError(_ctx.issues);
    }

    T result = value; // Safe: passed is! check above

    final validators = _validators;
    for (var i = 0; i < validators.length; i++) {
      final error = validators[i](result);
      if (error != null) {
        // Reuse the issue when path is empty — saves one allocation per error.
        if (pathOrNull == null && error.value == value) {
          _ctx.issues.add(error);
        } else {
          _ctx.issues.add(ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: pathOrNull,
          ));
        }
      }
    }

    if (_ctx.issues.isNotEmpty) {
      throw ZardError(_ctx.issues);
    }

    final transforms = _transforms;
    for (var i = 0; i < transforms.length; i++) {
      result = transforms[i](result);
    }

    return result;
  }

  ZardResult<T> safeParse(dynamic value, {String path = ''}) {
    try {
      final parsed = parse(value, path: path);
      return ZardResult<T>(success: true, data: parsed);
    } on ZardError catch (e) {
      return ZardResult<T>(success: false, error: e);
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
