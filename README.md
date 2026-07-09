<p align="center">
  <img src="./assets/logo.png" width="200px" align="center" alt="Zard logo" />
<h1 align="center">Zard</h1>
<br>
<p align="center">
<a href="https://zard-docs.vercel.app/">🛡️ Zard Documentation</a>
<br/>
    Zard is a schema validation and transformation library for Dart, inspired by the popular <a href="https://github.com/colinhacks/zod">Zod</a> library for JavaScript. With Zard, you can define schemas to validate and transform data easily and intuitively.
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
  zard: latest
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

Zard allows you to define schemas for various data types. Below are several examples of how to use Zard, including handling errors either by using `parse` (which throws errors) or `safeParse` (which returns a `ZardResult`).

<br>

### Defining Schemas

#### String Example

```dart
import 'package:zard/zard.dart';

void main() {
// String validations with minimum length and email format check.
  final schema = z.string().min(3).email();

// Using parse (throws ZardError on failure)
  try {
    final result = schema.parse('example@example.com');
    print(result); // example@example.com
  } on ZardError catch (e) {
    print(e.issues.first.message);
  }

// Using safeParse (never throws; returns ZardResult)
  final result = schema.safeParse('hi'); // too short
  if (!result.success) {
    for (final issue in result.error!.issues) {
      print('${issue.type}: ${issue.message}');
    } else {
      print(result.data);
    }
  }
}
```

<br>

## ⚡ Performance

After a substantial perf refactor (precompiled regex, no-throw internal parse
path, lazy issues lists, single-lookup map access, etc.) Zard now meets or
beats Zod on most common operations. Numbers below come from
`test/src/benchmarks/run-all.sh` (Dart 3.x JIT, Node 24, manual Stopwatch
with 5k warmup + 100k measured iterations).

| Scenario               | Zard (Dart) | Zod (JS) | Yup (JS) |
| ---------------------- | ----------- | -------- | -------- |
| String valid           | **0.05 µs** | 0.11 µs  | 1.27 µs  |
| String invalid (throw) | **0.55 µs** | 19.67 µs | 29.28 µs |
| Small object (2 keys)  | **0.36 µs** | 0.37 µs  | 3.82 µs  |
| Medium object (5 keys) | 1.27 µs     | 0.83 µs  | 12.04 µs |
| Complex nested         | 2.93 µs     | 0.89 µs  | 40.62 µs |
| Transform              | **0.06 µs** | 0.24 µs  | 0.81 µs  |
| Default                | **0.01 µs** | 0.06 µs  | 0.74 µs  |
| Nullable               | **0.01 µs** | 0.04 µs  | 0.68 µs  |
| Union (string)         | **0.06 µs** | 0.14 µs  | 1.21 µs  |
| Union (int)            | **0.08 µs** | 0.16 µs  | 1.19 µs  |
| safeParse              | 0.28 µs     | 0.08 µs  | 4.92 µs  |

**Summary:**

- Faster than Zod on 8/11 scenarios (and orders of magnitude faster on the
  error path because Dart exceptions are cheaper than V8's).
- 6–60× faster than Yup across the board.
- Roughly 2–3× slower than Zod on medium/complex objects — the remaining gap
  is mostly V8 inline-cache magic on object access patterns that the Dart VM
  can't match (yet).

Run it yourself: `./test/src/benchmarks/run-all.sh`.

---

<br>

## 📊 Benchmark

Three benchmark surfaces ship with the package — pick the one that matches
your need:

- `test/src/benchmarks/zard_benchmark.dart` — manual Stopwatch, 5k warmup +
  100k timed iterations. Closest apples-to-apples comparison with the
  JS benchmarks (which use the same closure pattern). Run with `dart run`.
- `test/src/benchmarks/zard_harness_benchmark.dart` — uses
  [`benchmark_harness`](https://pub.dev/packages/benchmark_harness),
  auto-calibrated, polymorphic dispatch (numbers are higher because the JIT
  can't inline through `BenchmarkBase.run`). The canonical reference. Run
  with `dart run` for JIT, or `dart compile exe …` for AOT (closer to a
  Flutter release build).
- `test/src/benchmarks/zod_benchmark.js` / `yup_benchmark.js` — reference
  implementations in TypeScript for cross-engine comparison. Install with
  `npm install` (inside that directory) then `node …`.

Zard achieves on a typical laptop (Dart JIT):

- **~20M ops/sec** primitives (`z.string().min(3)`)
- **~2.7M ops/sec** small objects
- **~340k ops/sec** complex nested objects

---

<br>

#### Email validation

Zard added specific validations for emails using reusable patterns (RegExp). By default, `z.string().email()` validates using the HTML5 pattern (compatible with browser validation) which allows single-label domains (e.g.: `john@example`). It is possible to pass a `pattern` to choose a different behavior.

Available patterns in `z.regexes`:

- `html5Email` — pattern used by browsers (allows `john@example`).
- `email` — stricter, requires a TLD (e.g.: `example.com`).
- `rfc5322Email` — more complete implementation that follows the RFC 5322 specification (accepts quoted local-parts, tags, etc.).
- `unicodeEmail` — permissive for non-ASCII characters (good for international emails), but simple.

Quick examples:

```dart
// 1) HTML5 pattern (browser default)
final html5 = z.string().email();
print(html5.parse('john@example')); // valid with html5Email

// 2) Force HTML5 pattern explicitly
final html5explicit = z.string().email(pattern: z.regexes.html5Email);
print(html5explicit.parse('john@example'));

// 3) Stricter pattern (requires TLD)
final strict = z.string().email(pattern: z.regexes.email);
print(strict.parse('john@example.com')); // valid
// strict.parse('john@example'); // throws error

// 4) RFC5322 (more complete)
final rfc = z.string().email(pattern: z.regexes.rfc5322Email);
print(rfc.parse('"john.doe"@example.co.uk')); // valid if it meets RFC

// 5) Unicode (accepts non-ASCII characters)
final uni = z.string().email(pattern: z.regexes.unicodeEmail);
print(uni.parse('usuário@exemplo.com'));
```

Use the `pattern` when you want to precisely control which email formats are accepted in your domain or application.
<br>

#### URL validation

Zard adds a convenient validator for URLs via `z.string().url()` with options to restrict `hostname` and `protocol` using custom `RegExp`.

Examples:

```dart
import 'package:zard/zard.dart';

void main() {
  // 1) Default: accepts optional http(s) and generic hostname
  final urlSchema = z.string().url();
  print(urlSchema.parse('https://www.example.com'));

  // 2) Force hostname ending with .example.com
  final urlWithHostnameSchema =
      z.string().url(hostname: RegExp(r'^[\w\.-]+\.example\.com$'));
  print(urlWithHostnameSchema.parse('https://api.example.com/path'));

  // 3) Force protocol (e.g.: only https)
  final urlProtocolSchema = z.string().url(protocol: RegExp(r'^https:\/\/'));
  print(urlProtocolSchema.parse('https://secure.example.com'));

  // 4) Hostname + protocol customized simultaneously
  final urlAllSchema = z.string().url(
        hostname: RegExp(r'^[\w\.-]+\.example\.com$'),
        protocol: RegExp(r'^https:\/\/'),
      );
  print(urlAllSchema.parse('https://api.example.com/endpoint'));
}
```

Important notes:

- You can pass `RegExp` to `hostname` and/or `protocol`. Patterns with anchors `^` and `$` are accepted — the validator removes these anchors internally when composing the final regex to avoid conflicts.
- The case sensitivity (`isCaseSensitive`) of the `RegExp` you provide is respected; by default validation is case-insensitive when no `RegExp` specifies otherwise.
- The default behavior allows optional protocol (`http`/`https`). To force a protocol, provide an appropriate `RegExp` (e.g. `RegExp(r'^https:\/\/')`).

<br>

#### String transforms (uppercase / lowercase / trim / normalize)

Zard adds convenient helpers and validators for common string operations:

- `uppercase()` — validator: requires the value to already be all uppercase.
- `lowercase()` — validator: requires the value to already be all lowercase.
- `toUpperCase()` — transform: converts the value to uppercase.
- `toLowerCase()` — transform: converts the value to lowercase.
- `trim()` — transform: removes leading/trailing whitespace.
- `normalize()` — transform: removes accents/diacritics (uses `string_normalizer` package), removes control characters, trims and collapses multiple whitespace into a single space.

Examples:

```dart
import 'package:zard/zard.dart';

void main() {
  // 1) uppercase validator: accepts only strings already in UPPERCASE
  final mustBeUpper = z.string().uppercase();
  print(mustBeUpper.parse('ABC')); // ABC

  // 2) lowercase validator: accepts only strings already in lowercase
  final mustBeLower = z.string().lowercase();
  print(mustBeLower.parse('abc')); // abc

  // 3) Transform toUpperCase / toLowerCase
  print(z.string().toUpperCase().parse('hello')); // HELLO
  print(z.string().toLowerCase().parse('HELLO')); // hello

  // 4) Trim
  print(z.string().trim().parse(' hello ')); // hello

  // 5) Normalize (removes accents/diacritics, trim, collapse whitespace)
  print(z.string().normalize().parse(' áéí ')); // aei
}
```

<br>

#### String → Boolean (stringbool)

Zard provides a convenient schema to interpret strings as booleans via `z.stringbool()`.

It accepts boolean, numeric, and string values that represent true or false states.

Recognized tokens (case-insensitive, with trim):

- True: `1`, `true`, `yes`, `on`, `y`, `enabled`
- False: `0`, `false`, `no`, `off`, `n`, `disabled`

Examples:

```dart
import 'package:zard/zard.dart';

void main() {
  final strbool = z.stringbool();
  print(strbool.parse('1')); // true
  print(strbool.parse('yes')); // true
  print(strbool.parse('ON')); // true
  print(strbool.parse(' enabled ')); // true (trim + case-insensitive)
  print(strbool.parse('0')); // false
  print(strbool.parse('no')); // false
  print(strbool.parse(true)); // true
  print(strbool.parse(0)); // false

  // Unrecognized values throw ZardError
  // strbool.parse('maybe'); // throws ZardError
}
```

<br>

#### Advanced String Validators

Zard provides a series of specialized validators for common string types (URLs, IPs, hashes, etc.):

**Identifiers and UUIDs:**

- `guid()` — GUID/UUID v4
- `uuid(version)` — Generic UUID (v1-v8) or specific version
- `nanoid()` — Nano ID (21 characters)
- `ulid()` — ULID (Universally Unique Lexicographically Sortable Identifier)

**Networks and Protocols:**

- `httpUrl()` — HTTP/HTTPS URLs only
- `hostname()` — Valid hostname
- `ipv4()` — IPv4 address
- `ipv6()` — IPv6 address
- `mac()` — MAC address (e.g.: `AA:BB:CC:DD:EE:FF`)
- `cidrv4()` — IPv4 CIDR block (e.g.: `192.168.1.0/24`)
- `cidrv6()` — IPv6 CIDR block

**Encodings and Hashes:**

- `base64()` — Standard Base64
- `base64url()` — Base64 URL-safe
- `hex()` — Hexadecimal
- `hash(algorithm)` — Hash validated by algorithm (supports `sha1`, `sha256`, `sha384`, `sha512`, `md5`)
- `jwt()` — JSON Web Token

**Other Formats:**

- `emoji()` — A single emoji character

Examples:

```dart
import 'package:zard/zard.dart';

void main() {
  z.string().guid().parse('550e8400-e29b-41d4-a716-446655440000');
  z.string().uuid(version: 'v4').parse('550e8400-e29b-41d4-a716-446655440000');
  z.string().nanoid().parse('V1StGXR_Z5j3eK4CFLQ');
  z.string().ulid().parse('01ARZ3NDEKTSV4RRFFQ69G5FAV');
  z.string().httpUrl().parse('https://example.com');
  z.string().ipv4().parse('192.168.1.1');
  z.string().ipv6().parse('2001:0db8:85a3:0000:0000:8a2e:0370:7334');
  z.string().mac().parse('AA:BB:CC:DD:EE:FF');
  z.string().base64().parse('SGVsbG8gV29ybGQ=');
  z.string().hex().parse('48656C6C6F');
  z.string().hash('sha256').parse('e3b0c44298fc1c149afbf4c8996fb924...');
  z.string().jwt().parse('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
  z.string().emoji().parse('😀');
}
```

<br>

#### ISO 8601 Date/Time Validators

Zard provides specialized validators for ISO 8601 formats, accessible via the `z.iso.*` namespace:

- `z.iso.date()` — ISO Date (YYYY-MM-DD)
- `z.iso.time()` — ISO Time (HH:mm:ss or with milliseconds)
- `z.iso.datetime()` — ISO 8601 Date and Time (with or without Z)
- `z.iso.duration()` — ISO 8601 Duration (e.g.: P1DT2H3M4S)

Examples:

```dart
import 'package:zard/zard.dart';

void main() {
  print(z.iso.date().parse('2021-01-01')); // valid
  print(z.iso.time().parse('12:30:45')); // valid
  print(z.iso.datetime().parse('2021-01-01T12:30:45Z')); // valid
  print(z.iso.duration().parse('P1Y2M3DT4H5M6S')); // valid
}
```

<br>

#### Int Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.int().min(1).max(100);
  print(schema.parse(50)); // 50

  final result = schema.safeParse(0); // below min
  if (!result.success) {
    print(result.error!.issues.first.message);
  }
}
```

<br>

#### Double Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.double().min(1.0).max(100.0);
  print(schema.parse(50.5)); // 50.5

  final result = schema.safeParse(0.5);
  if (!result.success) {
    print(result.error!.issues.first.message);
  }
}
```

<br>

#### Boolean Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.bool();
  print(schema.parse(true)); // true

  final result = schema.safeParse('yes'); // wrong type
  print(result.success); // false
}
```

<br>

#### List Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.list(z.string().min(3));
  print(schema.parse(['abc', 'def'])); // [abc, def]

  final result = schema.safeParse(['ab', 'def']); // 'ab' too short
  if (!result.success) {
    for (final issue in result.error!.issues) {
      print('${issue.path}: ${issue.message}');
    }
  }
}
```

<br>

#### Map / Object Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string().min(3),
    'age': z.int().min(0),
    'email': z.string().email(),
  }).refine(
    (value) => value['age'] > 18,
    message: 'Age must be greater than 18',
  );

  final result = schema.safeParse({
    'name': 'John Doe',
    'age': 20,
    'email': 'john.doe@example.com',
  });
  print(result.success); // true
  print(result.data);

  final result2 = schema.safeParse({
    'name': 'John Doe',
    'age': 10,
    'email': 'john.doe@example.com',
  });
  print(result2.success); // false
  print(result2.error!.issues.first.message); // Age must be greater than 18
}
```

<br>

#### Object Utility Methods

`ZMap` (and `ZInterface`) schemas support Zod-parity utility methods for transforming the schema shape:

```dart
import 'package:zard/zard.dart';

void main() {
  final userSchema = z.map({
    'name': z.string(),
    'age': z.int(),
    'email': z.string().email().optional(),
  });

  // partial(): all (or specific) fields become optional
  final partialUser = userSchema.partial();
  print(partialUser.parse({'name': 'Alice'})); // {name: Alice}

  final partialAge = userSchema.partial(keys: ['age']);
  print(partialAge.parse({'name': 'Bob', 'email': 'bob@x.com'}));

  // required(): all (or specific) optional fields become required
  final requiredUser = userSchema.required();

  // merge(): combine two schemas (second wins on conflicts)
  final withRole = userSchema.merge(z.map({'role': z.string()}));
  print(withRole.parse({'name': 'Carol', 'age': 30, 'role': 'admin'}));

  // extend(): add extra fields
  final extended = userSchema.extend({'phone': z.string().optional()});

  // pick(): keep only named fields
  final nameOnly = userSchema.pick(['name']);
  print(nameOnly.parse({'name': 'Dave'}));

  // omit(): remove named fields
  final noEmail = userSchema.omit(['email']);

  // keyof(): enum schema of the schema's keys
  final keys = userSchema.keyof();
  print(keys.parse('name')); // name
  print(keys.safeParse('unknown').success); // false
}
```

<br>

#### Date Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.date();
  print(schema.parse(DateTime.now()).year); // current year

  final result = schema.safeParse('2025-11-26');
  if (result.success) {
    print(result.data); // DateTime instance
  }
}
```

<br>

#### Enum Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.$enum(['pending', 'active', 'inactive']);
  print(schema.parse('active')); // active

  final result = schema.safeParse('unknown');
  print(result.success); // false

  // Extract or exclude values
  final active = schema.extract(['active', 'pending']);
  final noInactive = schema.exclude(['inactive']);
}
```

<br>

#### Default Value Example

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string(),
    'status': z.string().$default('active'),
    'age': z.int().$default(18),
  });

  // Absent fields use their defaults
  print(schema.parse({'name': 'John'}));
  // {name: John, status: active, age: 18}

  // Present-null fields also get the default
  print(schema.parse({'name': 'Jane', 'status': null, 'age': null}));
  // {name: Jane, status: active, age: 18}
}
```

<br>

#### Coerce Example

```dart
import 'package:zard/zard.dart';

void main() {
  print(z.coerce.int().parse('123')); // 123
  print(z.coerce.double().parse('3.14')); // 3.14
  print(z.coerce.bool().parse('true')); // true
  print(z.coerce.string().parse(123)); // "123"
  print(z.coerce.date().parse('2025-11-26')); // DateTime
}
```

<br>

#### Lazy Schema Example (Circular References)

```dart
import 'package:zard/zard.dart';

void main() {
  // Recursive schema for a tree structure
  late Schema<Map<String, dynamic>> nodeSchema;
  nodeSchema = z.map({
    'value': z.string(),
    'children': z.list(z.lazy(() => nodeSchema)).optional(),
  });

  final tree = nodeSchema.parse({
    'value': 'root',
    'children': [
      {'value': 'child1'},
      {
        'value': 'child2',
        'children': [
          {'value': 'grandchild'},
        ],
      },
    ],
  });

  print(tree['value']); // root
  print((tree['children'] as List).length); // 2
}
```

<br>

### Advanced Features 🎯

#### Transform Values

```dart
import 'package:zard/zard.dart';

void main() {
  // transform(): same output type
  final upper = z.string().transform((s) => s.toUpperCase());
  print(upper.parse('hello')); // HELLO

  // transformTyped(): change output type
  final length = z.string().transformTyped<int>((s) => s.length);
  print(length.parse('hello')); // 5

  // Chain transforms on object fields
  final schema = z.map({
    'email': z.string().email().transform((v) => v.toLowerCase()),
    'name': z.string().transform((v) => v.toUpperCase()),
  });
  print(schema.parse({'email': 'JOHN@X.COM', 'name': 'john'}));
  // {email: john@x.com, name: JOHN}
}
```

<br>

#### Optional and Nullable Fields

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string(),
    'nickname': z.string().optional(), // key may be absent
    'middleName': z.string().nullable(), // value may be null (key must be present)
    'age': z.int().nullish(), // key may be absent OR value may be null
  });

  final result = schema.safeParse({
    'name': 'John Doe',
    'middleName': null,
    'age': null,
  });

  if (result.success) {
    print(result.data); // {name: John Doe, middleName: null, age: null}
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
  }).strict(); // reject unknown keys

  final result = schema.safeParse({
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '123-456-7890', // not in schema
  });
  print(result.success); // false
  print(result.error!.issues.first.message); // Unexpected key "phone" found in object
}
```

<br>

#### Refine (Custom Validation)

```dart
import 'package:zard/zard.dart';

void main() {
  // Single-field refine
  final schema = z.int().refine((n) => n % 2 == 0, message: 'Must be even');
  print(schema.parse(4)); // 4
  print(schema.safeParse(3).success); // false

  // Cross-field refine on a map
  final passwords = z
      .map({'password': z.string().min(8), 'confirm': z.string()})
      .refine(
        (data) => data['password'] == data['confirm'],
        message: 'Passwords must match',
      );

  final result = passwords.safeParse({
    'password': 'secret123',
    'confirm': 'different',
  });
  print(result.error!.issues.first.message); // Passwords must match
}
```

<br>

#### Async Refine (`refineAsync`)

`refine()` is synchronous. When your validation needs to `await` something (a
database lookup, an HTTP call), use `refineAsync()`. It is honored only by
`parseAsync()` / `safeParseAsync()`. Calling the synchronous `parse()` on a
schema that carries an async refinement throws a `StateError` telling you to use
`parseAsync`.

```dart
import 'package:zard/zard.dart';

Future<void> main() async {
  final username = z.string().min(3).refineAsync(
        (value) async => await isUsernameAvailable(value),
        message: 'Username already taken',
      );

  print(await username.parseAsync('alice')); // alice (if available)

  final result = await username.safeParseAsync('bob');
  if (!result.success) {
    print(result.error!.issues.first.message); // Username already taken
  }

  // Sync parse is not allowed on async-refined schemas:
  // username.parse('alice'); // throws StateError
}
```

<br>

#### Pipe (Composing Schemas)

`.pipe(next)` feeds the parsed/transformed output of one schema into another,
composing them linearly. This is ideal for parsing then re-validating a
transformed value:

```dart
import 'package:zard/zard.dart';

void main() {
  // Parse a string into an int, then validate the int is non-negative.
  final schema = z.string().transform(int.parse).pipe(z.int().min(0));

  print(schema.parse('42')); // 42
  print(schema.safeParse('-1').success); // false
}
```

Issues from either stage propagate with their original paths, and it works
inside `z.map`/`z.list` (the no-throw hot path is respected).

<br>

#### Discriminated Union

`z.union([...])` tries each variant sequentially. A **discriminated union**
instead reads a discriminator field from the input and dispatches directly to
the matching variant — faster, and with a precise error when the discriminator
matches no variant. Each variant is expected to be a `z.map`/`z.interface`
containing the discriminator key (typically a `z.$enum` or literal).

```dart
import 'package:zard/zard.dart';

void main() {
  final shape = z.discriminatedUnion('type', [
    z.map({'type': z.$enum(['circle']), 'radius': z.double()}),
    z.map({'type': z.$enum(['square']), 'side': z.double()}),
  ]);

  print(shape.parse({'type': 'circle', 'radius': 2.0})); // {type: circle, radius: 2.0}

  final bad = shape.safeParse({'type': 'triangle'});
  print(bad.error!.issues.first.type); // discriminated_union_error
}
```

<br>

### ZardResult API

`safeParse()` and `safeParseAsync()` return a `ZardResult<T>` with the following interface:

| Member                          | Description                                          |
| ------------------------------- | ---------------------------------------------------- |
| `result.success`                | `true` if parsing succeeded                          |
| `result.data`                   | The parsed value (non-null when `success` is `true`) |
| `result.error`                  | The `ZardError` (non-null when `success` is `false`) |
| `result.unwrap()`               | Returns `data` or throws `ZardError`                 |
| `result.unwrapOrNull()`         | Returns `data` or `null` — never throws              |
| `result.when(success:, error:)` | Pattern-match on success/failure                     |

```dart
import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string().min(2),
    'age': z.int().min(0),
  });

  final result = schema.safeParse({'name': 'A', 'age': -1});

  // unwrap — throws on failure
  try {
    final data = result.unwrap();
  } on ZardError catch (e) {
    print('Failed: ${e.issues.length} issues');
  }

  // unwrapOrNull — null on failure
  print(result.unwrapOrNull()); // null

  // when — pattern match
  result.when(
    success: (data) => print('ok: $data'),
    error: (err) => print('fail: ${err.issues.first.message}'),
  );
}
```

<br>

### Error Formatting

Zard exposes three error-formatting helpers on the `z` object:

#### `z.flattenError(error)`

Collapses all issues into a flat `{formErrors, fieldErrors}` structure. `fieldErrors` keys are the top-level field path segments.

```dart
final flattened = z.flattenError(result.error!);
print(flattened.formErrors); // root-level errors
print(flattened.fieldErrors); // {'name': [...], 'age': [...]}
// firstErrors: one message per field (handy for form hints)
print(flattened.firstErrors); // {'name': 'Value must be at least 2 characters long', ...}
```

#### `z.treeifyError(error)`

Builds a nested tree reflecting the path structure of the issues.

```dart
final tree = z.treeifyError(result.error!);
print(tree.errors); // root-level error messages
print(tree.properties?['name']?.errors); // field-level messages
print(tree.items?[0]?.errors); // list-item-level messages
```

#### `z.prettifyError(error)`

Returns a human-readable multi-line string.

```dart
print(z.prettifyError(result.error!));
// ✖ Value must be at least 2 characters long
// → at name
// ✖ Value must be at least 0
// → at age
```

<br>

### Async Validation

```dart
import 'package:zard/zard.dart';

void main() async {
  final schema = z.string().min(3);

  // parseAsync accepts a plain value or a Future
  final value = await schema.parseAsync(Future.value('hello'));
  print(value); // hello

  // safeParseAsync returns a Future<ZardResult<T>>
  final result = await schema.safeParseAsync(Future.value('hi'));
  print(result.success); // false
}
```

<br>

### inferType

`z.inferType` combines a `ZMap` schema with a factory function, returning a typed schema that parses and converts in one step.

```dart
import 'package:zard/zard.dart';

class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
}

void main() {
  final schema = z.map({'name': z.string(), 'age': z.int()});

  final userType = z.inferType<User>(
    fromMap: (m) => User(name: m['name'] as String, age: m['age'] as int),
    mapSchema: schema,
  );

  final user = userType.parse({'name': 'Alice', 'age': 30});
  print(user.name); // Alice
}
```

<br>

### Error Handling with ZardError 😵‍💫

When a validation fails, Zard throws `ZardError`. Each `ZardIssue` inside it contains:

- **`message`** — a descriptive message about what went wrong.
- **`type`** — the error type (e.g., `min_error`, `max_error`, `type_error`, `required_error`).
- **`value`** — the value that failed validation.
- **`path`** — dot-notation path to the failing field (e.g., `address.zip` or `items[0].name`).

Two parsing methods:

1. **`parse()`** — throws `ZardError` on failure.
2. **`safeParse()`** — returns `ZardResult<T>`; never throws.
   <br>

### Similarity to Zod

Zard was inspired by Zod, a powerful schema validation library for JavaScript. Just like Zod, Zard provides an easy-to-use API for defining and transforming schemas. The main difference is that Zard is built specifically for Dart and Flutter, harnessing the power of Dart's language features.
<br>

## Contribution

Contributions are welcome! Feel free to open issues and pull requests on the [GitHub repository](https://github.com/evandersondev/zard).
<br>

## License

## This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

Made with ❤️ for Dart/Flutter developers! 🎯✨

<br />

## Contributors

<div style={{textAlign: 'center', margin: '2rem 0'}}>
  <a href="https://github.com/evandersondev/zard/graphs/contributors">
    <img style={{width: 24, height: 24}} src="https://contrib.rocks/image?repo=evandersondev/zard" alt="Contributors" />
  </a>
</div>
```
