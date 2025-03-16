# Zard 🧩

Zard is a schema validation and transformation library for Dart, inspired by the popular [Zod](https://github.com/colinhacks/zod) library for JavaScript. With Zard, you can define schemas to validate and transform data easily and intuitively.

<br>

### Support 💖

If you find Darto useful, please consider supporting its development 🌟[Buy Me a Coffee](https://buymeacoffee.com/evandersondev).🌟 Your support helps us improve the framework and make it even better!

<br>

## Installation 📦

Add the following line to your `pubspec.yaml`:

```yaml
dependencies:
  zard: ^0.0.1
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
  final schema = z.string().min(3).max(10).email(message: "Invalid email address").optional();

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
  final schema = z.int().min(1).max(100).optional();

  final result = schema.parse(50);
  print(result); // 50

  final nullResult = schema.parse(null);
  print(nullResult); // null
}
```

<br>

#### Double

```dart
import 'package:zard/zard.dart';

void main() {
  // Double validations
  final schema = z.doubleType().min(1.0).max(100.0).optional();

  final result = schema.parse(50.5);
  print(result); // 50.5

  final nullResult = schema.parse(null);
  print(nullResult); // null
}
```

<br>

#### Boolean

```dart
import 'package:zard/zard.dart';

void main() {
  // Boolean validations
  final schema = z.boolean().optional();

  final result = schema.parse(true);
  print(result); // true

  final nullResult = schema.parse(null);
  print(nullResult); // null
}
```

<br>
#### List

```dart
import 'package:zard/zard.dart';

void main() {
  // List validations
  final schema = z.list(z.string().min(3)).optional();

  final result = schema.parse(["abc", "def"]);
  print(result); // [abc, def]

  final nullResult = schema.parse(null);
  print(nullResult); // null
}
```

<br>

#### Map

```dart
import 'package:zard/zard.dart';

void main() {
  // Map validations
  final schema = z.map({
    'name': z.string().min(3).optional(),
    'age': z.int().min(1).optional(),
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
      print('Error: ${error.message}, Type: ${error.type}, Value: ${error.value}');
    }
  }

  // or
  print
  print(schema.getErrors());
  // [ZardError(message: Value must be at least 10, type: min_error, value: 5)]
}
```

In this example, if the value `5` does not meet the minimum requirement of `10`, Zard will return a `ZardError` object containing the error details.

<br>

### Available Methods

Here is a list of all the currently available methods in Zard:

#### ZString

- `min(int length, {String? message})`
- `max(int length, {String? message})`
- `email({String? message})`
- `url({String? message})`
- `length(int length, {String? message})`
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

<br>

#### ZInt

- `min(int length, {String? message})`
- `max(int length, {String? message})`
- `positive({String? message})`
- `nonnegative({String? message})`
- `negative({String? message})`
- `multipleOf(int divisor, {String? message})`
- `step(int stepValue, {String? message})`
- `optional()`

<br>

#### ZDouble

- `min(double length, {String? message})`
- `max(double length, {String? message})`
- `positive({String? message})`
- `nonnegative({String? message})`
- `negative({String? message})`
- `multipleOf(double divisor, {String? message})`
- `step(double stepValue, {String? message})`
- `optional()`

<br>

#### ZBoolean

- `boolean({String? message})`
- `optional()`

<br>

#### ZList

- `list(Schema itemSchema)`
- `optional()`

<br>

#### ZMap

- `map(Map<String, Schema> schemas)`
- `optional()`

<br>

#### ZEnum

- `ZEnum(List<String> list, {String? message})`
- `extract(List<String> list)`
- `exclude(List<String> list)`
- `optional()`

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
