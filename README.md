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
  zard: ^0.0.24
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

#### Date Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Date validations
  final schema = z.date();

  try {
    final result = schema.parse(DateTime.now());
    print("Parsed Value: $result"); // 2025-11-26T10:30:00.000
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  final safeResult = schema.safeParse("2025-11-26");
  if (!safeResult.success) {
    print("Safe Error: ${safeResult.error}");
  } else {
    print("Safe Parsed Value: ${safeResult.data}");
  }
}
```

<br>

#### Enum Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Enum validations with allowed values
  final schema = z.$enum(['pending', 'active', 'inactive']);

  try {
    final result = schema.parse('active');
    print("Parsed Value: $result"); // active
  } catch (e) {
    print("Errors (parse): ${schema.getErrors()}");
  }

  final safeResult = schema.safeParse('unknown');
  if (!safeResult.success) {
    print("Safe Error: Value must be one of [pending, active, inactive]");
  } else {
    print("Safe Parsed Value: ${safeResult.data}");
  }

  // Extract or exclude values from enum
  final extractedSchema = schema.extract(['active', 'pending']);
  print("Extracted: $extractedSchema"); // Only allows 'active' and 'pending'

  final excludedSchema = schema.exclude(['inactive']);
  print("Excluded: $excludedSchema"); // Allows everything except 'inactive'
}
```

<br>

#### Default Value Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Define default values for schemas
  final schema = z.map({
    'name': z.string(),
    'status': z.string().$default('active'),
    'age': z.int().$default(18),
  });

  // When 'status' and 'age' are omitted, defaults are used
  final result = schema.parse({
    'name': 'John Doe',
  });
  print(result); // {name: John Doe, status: active, age: 18}

  // When values are explicitly null, defaults are applied
  final result2 = schema.parse({
    'name': 'Jane Doe',
    'status': null,
    'age': null,
  });
  print(result2); // {name: Jane Doe, status: active, age: 18}

  // When values are provided, they override defaults
  final result3 = schema.parse({
    'name': 'Bob Smith',
    'status': 'inactive',
    'age': 30,
  });
  print(result3); // {name: Bob Smith, status: inactive, age: 30}
}
```

<br>

#### Coerce Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Coerce converts values to the expected type
  final intSchema = z.coerce.int().parse("123");
  print("Coerced int: $intSchema"); // 123

  final doubleSchema = z.coerce.double().parse("3.14");
  print("Coerced double: $doubleSchema"); // 3.14

  final boolSchema = z.coerce.bool().parse("true");
  print("Coerced bool: $boolSchema"); // true

  final stringSchema = z.coerce.string().parse(123);
  print("Coerced string: $stringSchema"); // "123"

  final dateSchema = z.coerce.date().parse("2025-11-26");
  print("Coerced date: $dateSchema"); // 2025-11-26T00:00:00.000
}
```

<br>

#### Lazy Schema Example

```dart
import 'package:zard/zard.dart';

void main() {
  // Lazy schemas are useful for recursive or circular schema definitions
  late Schema<Map<String, dynamic>> userSchema;

  userSchema = z.map({
    'name': z.string(),
    'email': z.string().email(),
    'friends': z.lazy(() => userSchema).list().optional(),
  });

  final user = userSchema.parse({
    'name': 'John Doe',
    'email': 'john@example.com',
    'friends': [
      {
        'name': 'Jane Doe',
        'email': 'jane@example.com',
      }
    ],
  });
  print(user); // Recursively parsed user with friends
}
```

<br>

### Advanced Features 🎯

#### Transform Values

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'email': z.string().email().transform((value) => value.toLowerCase()),
    'name': z.string().transform((value) => value.toUpperCase()),
  });

  final result = schema.parse({
    'email': 'JOHN@EXAMPLE.COM',
    'name': 'john doe',
  });
  print(result); // {email: john@example.com, name: JOHN DOE}
}
```

<br>

#### Optional and Nullable Fields

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string(),
    'nickname': z.string().optional(), // Can be omitted
    'middleName': z.string().nullable(), // Can be null if provided
    'age': z.int().nullish(), // Can be omitted or null
  });

  final result = schema.safeParse({
    'name': 'John Doe',
    'age': null,
  });

  if (result.success) {
    print(result.data); // {name: John Doe, age: null}
  }
}
```

<br>

#### Strict Mode

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string(),
    'email': z.string().email(),
  }).strict(); // Disallow extra fields

  // This will throw an error due to the extra 'phone' field
  try {
    final result = schema.parse({
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '123-456-7890', // Extra field not allowed
    });
  } catch (e) {
    print("Error: Unexpected key 'phone' found in object");
  }
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
