import 'package:zard/src/schemas/z_interface.dart';
import 'package:zard/src/schemas/z_lazy.dart';
import 'package:zard/zard.dart';

import 'schemas/z_coerce_container.dart';

typedef Validator<T> = String? Function(T value);

class Zard {
  ZardType inferType(
          {required dynamic Function(Map<String, dynamic>) fromMap,
          required Schema<Map<String, dynamic>> mapSchema}) =>
      ZardType(fromMap: fromMap, mapSchema: mapSchema);

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
  ZString string({String? message}) => ZString(message: message);

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
  ZInt int({String? message}) => ZInt(message: message);

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
  ZDouble double({String? message}) => ZDouble(message: message);

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
      ZMap(schema, message: message);

  ZInterface interface(Map<String, Schema> rawSchemas, {String? message}) =>
      ZInterface(rawSchemas, message: message);

  LazySchema lazy(Schema Function() schemaThunk) => LazySchema(schemaThunk);

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
      ZList(itemSchema, message: message);

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
  ZBool bool({String? message}) => ZBool(message: message);

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
  ZDate date({String? message}) => ZDate(message: message);

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
  ZEnum enumerate(List<String> values, {String? message}) =>
      ZEnum(values, message: message);

  /// Make a parse type coercion.
  /// ```dart
  /// final schema = z.coerce.string();
  /// final result = schema.parse(123);
  /// print(result); // "123"
  /// ```
  ZCoerce get coerce => ZCoerce();
}

final z = Zard();
