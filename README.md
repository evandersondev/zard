<p align="center">
  <img src="./assets/logo.png" width="200px" align="center" alt="Zard logo" />
  <h1 align="center">Zard</h1>
  <br>
  <p align="center">
  <a href="https://zard-docs.vercel.app/">🛡️ Zard Documentation</a>
  <br/>
    Zard is a schema validation and transformation library for Dart, inspired by the popular  <a href="https://github.com/colinhacks/zod">Zod</a> library for JavaScript. With Zard, you can define schemas to validate and transform data easily and intuitively.
  </p>
</p>

<br/>

### Support 💖

If you find Zard useful, please consider supporting its development 🌟 [Buy Me a Coffee](https://buymeacoffee.com/evandersondev) 🌟. Your support helps us improve the framework and make it even better!

<br>

## Installation 📦

Add the following line to your `pubspec.yaml`:

```yaml
dependencies:
  zard: ^0.0.22
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

Zard allows you to define schemas for various data types. Below are several examples of how to use Zard, including handling errors either by using `parse` (which throws errors) or `safeParse` (which returns a success flag and error details).

<br>

### Defining Schemas

#### String Example

```dart
import 'package:zard/zard.dart';

void main() {
  // String validations with minimum and maximum length and email format check.
  final schema = z.string().min(3).max(10).email(message: "Invalid email address");

  // Using parse (throws if there is an error)
  try {
    final result = schema.parse("example@example.com");
    print("Parsed Value: $result"); // example@example.com
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  // Using safeParse (doesn't throw; returns error info in result object)
  final safeResult = schema.safeParse("Hi"); // "Hi" is too short
  if (!safeResult['success']) {
    safeResult['errors'].forEach((error) => print("Safe Error: $error")); // Output error messages 😱
  } else {
    print("Safe Parsed Value: ${safeResult['data']}");
  }
}
```

<br>

#### Int Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Integer validations with minimum and maximum checks.
  final schema = z.int().min(1).max(100);

  // Using parse
  try {
    final result = schema.parse(50);
    print("Parsed Value: $result"); // 50
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  // Using safeParse with error handling
  final safeResult = schema.safeParse(5); // example: if 5 is below the minimum, it returns errors
  if (!safeResult['success']) {
    safeResult['errors'].forEach((error) => print("Safe Error: $error")); // Output error messages
  } else {
    print("Safe Parsed Value: ${safeResult['data']}");
  }
}
```

<br>

#### Double Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Double validations with minimum and maximum checks.
  final schema = z.doubleType().min(1.0).max(100.0);

  try {
    final result = schema.parse(50.5);
    print("Parsed Value: $result"); // 50.5
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  final safeResult = schema.safeParse(0.5);
  if (!safeResult['success']) {
    safeResult['errors'].forEach((error) => print("Safe Error: $error")); // Outputs error message if invalid
  } else {
    print("Safe Parsed Value: ${safeResult['data']}");
  }
}
```

<br>

#### Boolean Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Boolean validations
  final schema = z.boolean();

  try {
    final result = schema.parse(true);
    print("Parsed Value: $result"); // true
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  final safeResult = schema.safeParse(false);
  if (!safeResult['success']) {
    safeResult['errors'].forEach((error) => print("Safe Error: $error"));
  } else {
    print("Safe Parsed Value: ${safeResult['data']}");
  }
}
```

<br>

#### List Example

```dart
import 'package:zard/zard.dart';

void main() {
  // List validations with inner string schema validations.
  final schema = z.list(z.string().min(3));

  try {
    final result = schema.parse(["abc", "def"]);
    print("Parsed Value: $result"); // [abc, def]
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  final safeResult = schema.safeParse(["ab", "def"]); // "ab" is too short
  if (!safeResult['success']) {
    safeResult['errors'].forEach((error) => print("Safe Error: $error"));
  } else {
    print("Safe Parsed Value: ${safeResult['data']}");
  }
}
```

<br>

#### Map Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Map validations combining multiple schemas
  final schema = z.map({
    'name': z.string().min(3).nullable(),
    'age': z.int().min(1).nullable(),
    'email': z.string().email()
  }).refine((value) {
    return value['age'] > 18;
  }, message: 'Age must be greater than 18');

  final result = schema.safeParse({
    'name': 'John Doe',
    'age': 20,
    'email': 'john.doe@example.com',
  });
  print(result);

  final result2 = schema.safeParse({
    'name': 'John Doe',
    'age': 10,
    'email': 'john.doe@example.com',
  });
  print(result2);
}
```

<br>

### Error Handling with ZardError 😵‍💫

When a validation fails, Zard provides detailed error information via the `ZardError` class. Each error object contains:

- **message**: A descriptive message about what went wrong.
- **type**: The type of error (e.g., `min_error`, `max_error`, `type_error`).
- **value**: The unexpected value that failed validation.

Zard supports two methods for validation:

1. **`parse()`**: Throws an exception if any validation fails.
2. **`safeParse()`**: Returns an object with a `success` flag and a list of errors without throwing exceptions.

<br>

### New Methods & Functionality 💡

Zard now supports additional methods to handle asynchronous validations and custom refine checks for Map schemas. These new methods help you integrate asynchronous operations and write custom validations easily!

- **Asynchronous Validation**

  - **`parseAsync()`**: Returns a `Future` that resolves with the parsed value or throws an error if validation fails.
  - **`safeParseAsync()`**: Works like `safeParse()`, but returns a `Future` with a success flag and error details.
  - These methods ensure that if your input is a `Future`, Zard waits for its resolution before parsing.

- **Refine Method on Map Schemas**

  - **`refine()`**: Allows you to add custom validation logic on `Map` schemas.
  - It accepts a function that receives the parsed value and returns a boolean. If the function returns `false`, a `refine_error` is added with a custom message.
  - This feature is especially useful for validating inter-dependent fields—for example, ensuring that an `age` field is greater than 18 in a user profile map.

- **InferType Method**
  - **`inferType()`**: Allows you to create a typed schema that validates a Map and transforms it into a specific model instance.
  - It combines a Map validation schema with a conversion function, enabling type-safe validation and transformation in a single operation.
  - This feature is especially useful for creating strongly-typed schemas for your data models while maintaining all validation capabilities including `refine()`.

Example usage of `refine()` in a Map schema:

```dart
final schema = z.map({
  'name': z.string(),
  'age': z.int(),
  'email': z.string().email()
}).refine((value) {
  return value['age'] > 18;
}, message: 'Age must be greater than 18');

final result = schema.safeParse({
  'name': 'John Doe',
  'age': 20,
  'email': 'john.doe@example.com',
});
print(result); // {success: true, data: {...}}

final result2 = schema.safeParse({
  'name': 'John Doe',
  'age': 10,
  'email': 'john.doe@example.com',
});
print(result2); // {success: false, errors: [...]}
```

Example usage of `inferType()`:

```dart
final userSchema = z.inferType<User>(
  fromMap: (map) => User.fromMap(map),
  mapSchema: schema,
).refine(
  (value) => value.age >= 18,
  message: 'User must be at least 18 years old',
);

final user = userSchema.parse({
  'name': 'John Doe',
  'age': 25,
});
print(user.name); // John Doe
```

<br>

### Similarity to Zod

Zard was inspired by Zod, a powerful schema validation library for JavaScript. Just like Zod, Zard provides an easy-to-use API for defining and transforming schemas. The main difference is that Zard is built specifically for Dart and Flutter, harnessing the power of Dart's language features.

<br>

## Contribution

Contributions are welcome! Feel free to open issues and pull requests on the [GitHub repository](https://github.com/evandersondev/zard).

<br>

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

Made with ❤️ for Dart/Flutter developers! 🎯✨

<div style={{textAlign: 'center', margin: '2rem 0'}}>
  <a href="https://github.com/evandersondev/zard/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=evandersondev/zard" alt="Contributors" />
  </a>
</div>

</div>
