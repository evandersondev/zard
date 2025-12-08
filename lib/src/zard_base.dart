import 'package:zard/src/schemas/z_string_bool.dart';
import 'package:zard/src/utils/iso.dart';
import 'package:zard/zard.dart';

import 'types/zard_error_formatter.dart' as formatter;
import 'utils/regexes.dart';

typedef Validator<T> = String? Function(T value);

class Zard {
  // Error formatting utilities
  ZardErrorTree treeifyError(ZardError error) => formatter.treeifyError(error);
  String prettifyError(ZardError error) => formatter.prettifyError(error);
  ZardFlattenedError flattenError(ZardError error) =>
      formatter.flattenError(error);

  ZardType<T> inferType<T>({
    required T Function(Map<String, dynamic>) fromMap,
    required Schema<Map<String, dynamic>> mapSchema,
  }) =>
      ZardType<T>(fromMap: fromMap, mapSchema: mapSchema);

  /// A schema for validating strings.
  /// ```md
  /// Types supported:
  /// - String
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - bool
  /// - List
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final stringSchema = z.string().min(3);
  /// final hello = stringSchema.parse('hello');
  /// ```
  ZString string({String? message}) => ZStringImpl(message: message);

  /// A schema for validating integers.
  /// ```md
  /// Types supported:
  /// - int
  ///
  /// Types not supported:
  /// - double
  /// - String
  /// - bool
  /// - List
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final intSchema = z.int().min(0).max(10);
  /// final age = intSchema.parse(5);
  /// ```
  ZInt int({String? message}) => ZIntImpl(message: message);

  /// A schema for validating doubles.
  /// ```md
  /// Types supported:
  /// - double
  ///
  /// Types not supported:
  /// - int
  /// - String
  /// - bool
  /// - List
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final doubleSchema = z.double().min(0).max(10);
  /// final sallary = doubleSchema.parse(5.5);
  /// ```
  ZDouble double({String? message}) => ZDoubleImpl(message: message);

  /// A schema that coerces values to double.
  /// ```md
  /// Types supported (with coercion):
  /// - String (must be parseable as a number)
  /// - int (converted to double)
  /// - double (passed through)
  ///
  /// Types not supported:
  /// - bool
  /// - List
  /// - Map
  /// - Non-numeric strings
  ///
  /// Examples:
  /// ```dart
  /// final schema = z.coerceDouble();
  /// final value1 = schema.parse('3.14'); // returns 3.14 (double)
  /// final value2 = schema.parse('42'); // returns 42.0 (double)
  /// final value3 = schema.parse(5); // returns 5.0 (double)
  /// final value4 = schema.parse(3.14); // returns 3.14 (double)
  /// ```
  ZCoerceDouble coerceDouble({String? message}) =>
      ZCoerceDouble(message: message);

  /// A schema for validating numbers (int or double).
  /// ```md
  /// Types supported:
  /// - int
  /// - double
  ///
  /// Types not supported:
  /// - String
  /// - bool
  /// - List
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final numSchema = z.num().min(0).max(10);
  /// final value = numSchema.parse(5); // returns 5 (int)
  /// final value2 = numSchema.parse(5.5); // returns 5.5 (double)
  /// ```
  ZNum num({String? message}) => ZNumImpl(message: message);

  /// A schema for validating maps.
  /// ```md
  /// Types supported:
  /// - Map<String, dynamic>
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - String
  /// - bool
  /// - List
  ///
  /// Examples:
  /// ```dart
  /// final mapSchema = z.map({
  /// 'name': z.string(),
  /// 'age': z.int(),
  /// 'sallary': z.double(),
  /// });
  /// final user = mapSchema.parse({
  /// 'name': 'John Doe',
  /// 'age': 30,
  /// 'sallary': 1000.0,
  /// });
  /// ```
  ZMap map(Map<String, Schema> schema, {String? message}) =>
      ZMapImpl(schema, message: message);

  ZInterface interface(Map<String, Schema> rawSchemas, {String? message}) =>
      ZInterfaceImpl(rawSchemas, message: message);

  LazySchema<T> lazy<T>(Schema<T> Function() schemaThunk) =>
      ZLazySchemaImpl<T>(schemaThunk);

  /// A schema for validating lists.
  /// ```md
  /// Types supported:
  /// - List
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - String
  /// - bool
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final listSchema = z.list(z.string());
  /// final list = listSchema.parse(['a', 'b', 'c']);
  /// ```
  ZList list(Schema itemSchema, {String? message}) =>
      ZListImpl(itemSchema, message: message);

  /// A schema for validating booleans.
  /// ```md
  /// Types supported:
  /// - bool
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - String
  /// - List
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final boolSchema = z.bool();
  /// final boolValue = boolSchema.parse(true);
  /// ```
  ZBool bool({String? message}) => ZBoolImpl(message: message);

  ///  A schema for validating dates.
  ///
  ///```md
  /// Types supported:
  /// - DateTime
  /// - String
  ///
  /// Formats supported:
  /// 2021-01-01
  /// 1/10/23
  /// 2021-01-01T00:00:00
  /// 2021-01-01T00:00:00.000
  /// 2021-01-01T00:00:00.000Z
  /// 2021-01-01T00:00:00.000+00:00
  /// 2021-01-01T00:00:00.000-00:00
  /// 2021-01-01T00:00:00.000+00:00Z
  ///
  /// Formats not supported:
  ///  Failure:
  /// 2023-13-12
  /// 0000-00-00
  /// 20130725
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - bool
  /// - List
  /// - Map
  ///```
  ///
  ///
  /// Examples:
  /// ```dart
  /// final dateSchema = z.date();
  /// final date = dateSchema.parse(DateTime.now());
  ///
  /// final date = dateSchema.parse('2021-01-01');
  /// ```
  ZDate date({String? message}) => ZDateImpl(message: message);

  /// A schema for validating enums.
  /// ```md
  /// Types supported:
  /// - List<string>
  ///
  /// Types not supported:
  /// - int
  /// - double
  /// - String
  /// - bool
  /// - Map
  ///
  /// Examples:
  /// ```dart
  /// final enumSchema = z.enumerate(['red', 'green', 'blue']);
  /// final roles = ['red', 'green', 'blue'];
  /// final result = enumSchema.parse(roles);
  /// ```
  ZEnum $enum(List<String> values, {String? message}) =>
      ZEnumImpl(values, message: message);

  /// Make a parse type coercion.
  /// ```dart
  /// final schema = z.coerce.string();
  /// final result = schema.parse(123);
  /// print(result); // "123"
  /// ```
  ZCoerce get coerce => ZCoerceImpl();

  /// A schema for validating files.
  /// ```dart
  /// final fileSchema = z.file();
  /// fileSchema.min(10_000); // minimum size (bytes)
  /// fileSchema.max(1_000_000); // maximum size (bytes)
  /// fileSchema.mime("image/png"); // MIME type
  /// fileSchema.mime(["image/png", "image/jpeg"]); // multiple MIME types
  /// ```
  ZFile file({String? message}) => ZFileImpl(message: message);

  Regexes get regexes => Regexes();

  ZStringBool stringbool({String? message}) =>
      ZStringBoolImpl(message: message);

  /// ISO string validation namespace
  /// Example:
  /// ```dart
  /// final isoDateSchema = z.iso.date();
  /// final isoTimeSchema = z.iso.time();
  /// final isoDatetimeSchema = z.iso.datetime();
  /// final isoDurationSchema = z.iso.duration();
  /// ```
  Iso get iso => Iso();
}

final z = Zard();
