import 'package:zard/src/schemas/schemas.dart';

import '../types/zard_error.dart';
import '../types/zard_issue.dart';

/// A discriminated union: a union whose variants share a common
/// **discriminator** key (typically a `z.$enum` or literal string field).
///
/// Unlike [ZUnion], which tries each variant sequentially, this reads the
/// discriminator value from the input map and dispatches **directly** to the
/// matching variant. That is both faster (no trial-and-error) and produces a
/// precise error when the discriminator value matches no variant.
///
/// Each variant is expected to be a `ZMap`/`ZInterface` that contains the
/// discriminator key.
///
/// Example:
/// ```dart
/// final schema = z.discriminatedUnion('type', [
///   z.map({'type': z.$enum(['circle']), 'radius': z.double()}),
///   z.map({'type': z.$enum(['square']), 'side': z.double()}),
/// ]);
/// schema.parse({'type': 'circle', 'radius': 1.0});
/// ```
abstract interface class ZDiscriminatedUnion extends Schema<dynamic> {
  final String discriminatorKey;
  final List<Schema> variants;

  ZDiscriminatedUnion(this.discriminatorKey, this.variants);

  /// Resolves the variant matching the discriminator value found in [value].
  /// Returns `null` when [value] is not a map, is missing the discriminator,
  /// or no variant accepts the discriminator value. In every `null` case at
  /// least one issue is appended to [sink].
  Schema? _resolveVariant(
      dynamic value, String? pathOrNull, List<ZardIssue> sink) {
    if (value == null) {
      sink.add(ZardIssue(
        message: 'Value is required and cannot be null',
        type: 'required_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    if (value is! Map) {
      sink.add(ZardIssue(
        message: 'Expected a Map for discriminated union',
        type: 'type_error',
        value: value,
        path: pathOrNull,
      ));
      return null;
    }

    final discriminatorValue = value[discriminatorKey];

    // Probe each variant's discriminator field with a throwaway sink; the
    // first variant that accepts the discriminator value wins.
    final probe = <ZardIssue>[];
    for (var i = 0; i < variants.length; i++) {
      final variant = variants[i];
      final discSchema = _discriminatorSchemaOf(variant);
      if (discSchema == null) continue;

      probe.clear();
      discSchema.parseInto(discriminatorValue, '', probe);
      if (probe.isEmpty) {
        return variant;
      }
    }

    sink.add(ZardIssue(
      message:
          'Invalid discriminator value "$discriminatorValue" for key "$discriminatorKey"',
      type: 'discriminated_union_error',
      value: discriminatorValue,
      path: pathOrNull,
    ));
    return null;
  }

  /// Extracts the schema registered under [discriminatorKey] for a variant,
  /// or `null` if the variant does not expose the discriminator field.
  Schema? _discriminatorSchemaOf(Schema variant) {
    if (variant is ZMap) return variant.schemas[discriminatorKey];
    if (variant is ZInterface) return variant.schemas[discriminatorKey];
    return null;
  }

  @override
  dynamic parse(dynamic value, {String path = ''}) {
    final pathOrNull = path.isEmpty ? null : path;
    final errors = <ZardIssue>[];

    final variant = _resolveVariant(value, pathOrNull, errors);
    if (variant == null) {
      throw ZardError(errors);
    }

    return variant.parse(value, path: path);
  }

  @override
  Object? parseInto(dynamic value, String path, List<ZardIssue> sink) {
    final pathOrNull = path.isEmpty ? null : path;

    final variant = _resolveVariant(value, pathOrNull, sink);
    if (variant == null) return null;

    return variant.parseInto(value, path, sink);
  }

  @override
  Future<dynamic> parseAsync(dynamic value, {String path = ''}) async {
    final pathOrNull = path.isEmpty ? null : path;
    final resolvedValue = value is Future ? await value : value;

    final errors = <ZardIssue>[];
    final variant = _resolveVariant(resolvedValue, pathOrNull, errors);
    if (variant == null) {
      throw ZardError(errors);
    }

    return variant.parseAsync(resolvedValue, path: path);
  }

  @override
  String toString() =>
      'ZDiscriminatedUnion($discriminatorKey, ${variants.toString()})';
}

class ZDiscriminatedUnionImpl extends ZDiscriminatedUnion {
  ZDiscriminatedUnionImpl(super.discriminatorKey, super.variants);
}
