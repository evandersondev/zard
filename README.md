# Zard 🧩

Zard is a schema validation and transformation library for Dart, inspired by the popular [Zod](https://github.com/colinhacks/zod) library for JavaScript. With Zard, you can define schemas to validate and transform data easily and intuitively.

<br>

### Support 💖

If you find Zard useful, please consider supporting its development 🌟[Buy Me a Coffee](https://buymeacoffee.com/evandersondev).🌟 Your support helps us improve the framework and make it even better!

<br>

## Installation 📦

Add the following line to your `pubspec.yaml`:

```yaml
dependencies:
  zard: ^0.0.4
```

Then, run:

```sh
flutter pub get
```

Or run:

```sh
dart pub add zard
```

<br>

## Usage 🚀

### Defining Schemas

Zard allows you to define schemas for various data types. Here are some examples of how to use Zard:

<br>

#### String

```dart
import 'package:zard/zard.dart';

void main() {
  // String validations
  final schema = z.string().min(3).max(10).email(message: "Invalid email address");

  final result = schema.parse("example@example.com");
  print(result); // example@example.com

  final nullResult = schema.parse(null);
  print(nullResult); // null
}
```

<br>

#### Int

```dart
import 'package:zard/zard.dart';

void main() {
  // Integer validations
  final schema = z.int().min(1).max(100);

  final result = schema.parse(50);
  print(result); // 50

  final nullResult = schema.parse(null);
  print(nullResult); // null
  print(schema.getErrors()); // {'success': false, 'error': [ZardError(message: 'Value must be at least 1', type: 'min_error', value: null)]}
}
```

<br>

#### Double

```dart
import 'package:zard/zard.dart';

void main() {
  // Double validations
  final schema = z.doubleType().min(1.0).max(100.0);

  final result = schema.parse(50.5);
  print(result); // 50.5

  final nullResult = schema.parse(null);
  print(nullResult); // null
  print(schema.getErrors()); // {'success': false, 'error': [ZardError(message: 'Value must be at least 1.0', type: 'min_error', value: null)]}
}
```

<br>

#### Boolean

```dart
import 'package:zard/zard.dart';

void main() {
  // Boolean validations
  final schema = z.boolean();

  final result = schema.parse(true);
  print(result); // true

  final nullResult = schema.parse(null);
  print(nullResult); // null
  print(schema.getErrors()); // {'success': false, 'error': [ZardError(message: 'Value must be true', type: 'boolean_error', value: null)]}
}
```

<br>

#### List

```dart
import 'package:zard/zard.dart';

void main() {
  // List validations
  final schema = z.list(z.string().min(3));

  final result = schema.parse(["abc", "def"]);
  print(result); // [abc, def]

  final nullResult = schema.parse(null);
  print(nullResult); // null
  print(schema.getErrors()); // {'success': false, 'error': [ZardError(message: 'Value must be at least 3 characters long', type: 'min_error', value: null)]}
}
```

<br>

#### Map

```dart
import 'package:zard/zard.dart';

void main() {
  // Map validations
  final schema = z.map({
    'name': z.string().min(3).nullable(),
    'age': z.int().min(1).nullable(),
  });

  final result = schema.parse({
    'name': 'John Doe',
    'age': 30,
  });
  print(result); // {name: John Doe, age: 30}

  final nullResult = schema.parse({
    'name': null,
    'age': null,
  });
  print(nullResult); // {name: null, age: null}
}
```

<br>

### Error Handling with ZardError

Zard provides comprehensive error handling through the `ZardError` class. When a validation fails, Zard returns a `ZardError` object that contains detailed information about the error.

#### ZardError Fields

- `message`: A descriptive message about the error.
- `type`: The type of error (e.g., `min_error`, `max_error`, `type_error`).
- `value`: The value that caused the error.

#### Example of Handling Errors

```dart
import 'package:zard/zard.dart';

void main() {
  // Integer validations
  final schema = z.int().min(10, message: 'Value must be at least 10');

  final result = schema.safeParse(5);

  if (!result['success']) {
    for (var error in result['errors']) {
      print('Error: $error');
    }
  }

  // or
  print(schema.getErrors());
  // [{'success': false, 'error': [ZardError(message: 'Value must be at least 10', type: 'min_error', value: 5)]}]
}
```

<br>

### New Methods & Functionality

In addition to the already available API, Zard now includes several new methods that provide increased flexibility when validating and transforming data. These methods allow you to control the behavior of a schema regarding null values, as well as manipulate object schemas.

#### .nullable()

Allows the schema to accept `null` values. When a schema is marked as nullable, if the parsed value is null, the validation and transformation steps are skipped and `null` is returned.

Example with primitive types:

```dart
final boolSchema = z.boolean().nullable();
final result = boolSchema.parse(null);
print(result); // Outputs: null
```

Example with Map schemas:

```dart
final userSchema = z.map({
  'name': z.string().min(3),
  'age': z.int().min(18).nullable(),
});

final user = userSchema.parse({
  'name': 'John Doe',
  'age': null,
});
print(user); // {name: "John Doe", age: null}
```

<br>

#### .optional()

Marks the schema as optional. When a schema is optional and the value is null, the validations are skipped and `null` is returned.

Example:

```dart
final userSchema = z.map({
  'name': z.string().min(3),
  'age': z.int().min(18).optional(),
});
final user = userSchema.parse({
  'name': 'John Doe',
});
print(user); // {name: "John Doe", age: null}
```

<br>

#### .omit()

Allows you to remove (or ignore) specific keys from a Map schema. This is useful when you want to validate an object but intentionally ignore certain fields.

Example:

```dart
final userSchema = z.map({
  'name': z.string().min(3),
  'age': z.int().min(18),
  'password': z.string().min(6),
}).omit(['password']);

final user = userSchema.parse({
  'name': 'John Doe',
  'age': 30,
  'password': 'secret123',
});
print(user); // ZMMap({name: "John Doe", age: 30})
```

<br>

#### .pick()

Allows you to select specific keys from a Map schema, effectively creating a new schema that only validates a subset of the original object's properties.

Example:

```dart
final userSchema = z.map({
  'name': z.string().min(3),
  'age': z.int().min(18),
  'password': z.string().min(6),
}).pick(['name', 'age']);

final user = userSchema.parse({
  'name': 'John Doe',
  'age': 30,
  'password': 'secret123',
});
print(user); // ZMap({name: "John Doe", age: 30})
```

<br>

#### .length()

For string and list schemas, the `.length()` method allows you to validate the exact length of the value. For strings, it ensures the string has exactly the specified number of characters; for lists, it ensures the list has exactly the specified number of items.

Example for string:

```dart
final schema = z.string().length(5, message: "String must be exactly 5 characters long");
final result = schema.parse("Hello");
print(result); // Hello
```

Example for list:

```dart
final schema = z.list(z.int()).length(3, message: "List must have 3 items");
final result = schema.parse([1, 2, 3]);
print(result); // [1, 2, 3]
```

<br>

### Available Methods

Here is a list of all the currently available methods in Zard:

#### ZString

- `min(int length, {String? message})`
- `max(int length, {String? message})`
- `length(int length, {String? message})`
- `email({String? message})`
- `url({String? message})`
- `uuid({String? message})`
- `cuid({String? message})`
- `cuid2({String? message})`
- `regex(RegExp regex, {String? message})`
- `endsWith(String suffix, {String? message})`
- `startsWith(String prefix, {String? message})`
- `contains(String substring, {String? message})`
- `datetime({String? message})`
- `date({String? message})`
- `time({String? message})`
- `trim()`
- `toLowerCase()`
- `toUpperCase()`
- `capitalize()`
- `optional()`
- `nullable()`

<br>

#### ZInt

- `min(int value, {String? message})`
- `max(int value, {String? message})`
- `positive({String? message})`
- `nonnegative({String? message})`
- `negative({String? message})`
- `multipleOf(int divisor, {String? message})`
- `step(int stepValue, {String? message})`
- `optional()`
- `nullable()`

<br>

#### ZDouble

- `min(double value, {String? message})`
- `max(double value, {String? message})`
- `positive({String? message})`
- `nonnegative({String? message})`
- `negative({String? message})`
- `multipleOf(double divisor, {String? message})`
- `step(double stepValue, {String? message})`
- `optional()`
- `nullable()`

<br>

#### ZBoolean

- `boolean({String? message})`
- `optional()`
- `nullable()`

<br>

#### ZList

- `list(Schema itemSchema)`
- `min(int length, {String? message})`
- `max(int length, {String? message})`
- `length(int length, {String? message})`
- `noempty({String? message})`
- `optional()`
- `nullable()`

<br>

#### ZMap

- `map(Map<String, Schema> schemas)`
- `optional()`
- `nullable()`
- `omit(List<String> keys)`
- `pick(List<String> keys)`
- `keyOf()` ZodEnum<["name", "age"]>

<br>

#### ZEnum

- `ZEnum(List<String> list, {String? message})`
- `extract(List<String> list)`
- `exclude(List<String> list)`
- `optional()`
- `nullable()`

<br>

### Similarity to Zod

Zard was inspired by Zod, a schema validation library for JavaScript. Just like Zod, Zard provides an easy-to-use API for defining validation and transformation schemas. The main difference is that Zard is specifically designed for Dart and Flutter, leveraging the features and syntax of the Dart language.

<br>

## Contribution

Contributions are welcome! Feel free to open issues and pull requests on the [GitHub repository](https://github.com/evandersondev/zard).

<br>

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Made with ❤️ for Dart/Flutter developers! 🎯
