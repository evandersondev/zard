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
  zard: ^0.0.26
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

#### Email validation

Zard acrescentou validações específicas para emails usando padrões (RegExp) reutilizáveis. Por padrão, `z.string().email()` valida usando o padrão HTML5 (compatível com a validação dos navegadores) que permite domínios de etiqueta única (ex: `john@example`). É possível passar um `pattern` para escolher outro comportamento.

Padrões disponíveis em `z.regexes`:

- `html5Email` — padrão usado por navegadores (permite `john@example`).
- `email` — mais estrito, exige um TLD (ex: `example.com`).
- `rfc5322Email` — implementação mais completa que segue a especificação RFC 5322 (aceita local-parts com aspas, tags, etc.).
- `unicodeEmail` — permissivo para caracteres não-ASCII (bom para emails internacionais), mas simples.

Exemplos rápidos:

```dart
// 1) padrão HTML5 (padrão do navegador)
final html5 = z.string().email();
print(html5.parse('john@example')); // válido com html5Email

// 2) forçar padrão HTML5 explicitamente
final html5explicit = z.string().email(pattern: z.regexes.html5Email);
print(html5explicit.parse('john@example'));

// 3) padrão mais estrito (exige TLD)
final strict = z.string().email(pattern: z.regexes.email);
print(strict.parse('john@example.com')); // válido
// strict.parse('john@example'); // lança erro

// 4) RFC5322 (mais completo)
final rfc = z.string().email(pattern: z.regexes.rfc5322Email);
print(rfc.parse('"john.doe"@example.co.uk')); // válido se atender RFC

// 5) Unicode (aceita caracteres não-ASCII)
final uni = z.string().email(pattern: z.regexes.unicodeEmail);
print(uni.parse('usuário@exemplo.com'));
```

Use o `pattern` quando quiser controlar exatamente quais formatos de e-mail são aceitos no seu domínio ou aplicação.

<br>

#### URL validation

Zard adiciona um validador conveniente para URLs via `z.string().url()` com opções para restringir `hostname` e `protocol` usando `RegExp` personalizados.

Exemplos:

```dart
import 'package:zard/zard.dart';

void main() {
  // 1) Padrão: aceita http(s) opcional e hostname genérico
  final urlSchema = z.string().url();
  print(urlSchema.parse('https://www.example.com'));

  // 2) Forçar hostname que termine com .example.com
  final urlWithHostnameSchema =
      z.string().url(hostname: RegExp(r'^[\w\.-]+\.example\.com$'));
  print(urlWithHostnameSchema.parse('https://api.example.com/path'));

  // 3) Forçar protocolo (por exemplo: somente https)
  final urlProtocolSchema = z.string().url(protocol: RegExp(r'^https:\/\/'));
  print(urlProtocolSchema.parse('https://secure.example.com'));

  // 4) Hostname + protocolo personalizados simultaneamente
  final urlAllSchema = z.string().url(
    hostname: RegExp(r'^[\w\.-]+\.example\.com$'),
    protocol: RegExp(r'^https:\/\/'),
  );
  print(urlAllSchema.parse('https://api.example.com/endpoint'));
}
```

Observações importantes:

- Você pode passar `RegExp` em `hostname` e/ou `protocol`. Padrões com âncoras `^` e `$` são aceitos — o validador remove esses anchors internamente ao compor a regex final para evitar conflitos.
- A sensibilidade a maiúsculas/minúsculas (`isCaseSensitive`) dos `RegExp` que você fornecer é respeitada; por padrão a validação é case-insensitive quando nenhum `RegExp` especifica o contrário.
- O comportamento padrão permite protocole opcional (`http`/`https`). Para forçar protocolo, forneça um `RegExp` apropriado (por exemplo `RegExp(r'^https:\/\/')`).

<br>

#### String transforms (uppercase / lowercase / trim / normalize)

Zard adiciona helpers e validadores convenientes para operações comuns em strings:

- uppercase() — validador: exige que o valor já esteja todo em maiúsculas.
- lowercase() — validador: exige que o valor já esteja todo em minúsculas.
- toUpperCase() — transform: converte o valor para maiúsculas.
- toLowerCase() — transform: converte o valor para minúsculas.
- trim() — transform: remove espaços do início/fim da string.
- normalize() — transform: remove acentos/diacríticos (usa package string_normalizer), remove caracteres de controle, faz trim e colapsa múltiplos whitespace em um único espaço.

Exemplos:

```dart
import 'package:zard/zard.dart';

void main() {
  // 1) Validador uppercase: aceita apenas strings já em MAIÚSCULAS
  final mustBeUpper = z.string().uppercase();
  expect(mustBeUpper.parse('ABC'), equals('ABC'));
  // mustBeUpper.parse('AbC'); // lança ZardError

  // 2) Validador lowercase: aceita apenas strings já em minúsculas
  final mustBeLower = z.string().lowercase();
  expect(mustBeLower.parse('abc'), equals('abc'));
  // mustBeLower.parse('aBc'); // lança ZardError

  // 3) Transform toUpperCase / toLowerCase
  final toUpper = z.string().toUpperCase();
  expect(toUpper.parse('hello'), equals('HELLO'));

  final toLower = z.string().toLowerCase();
  expect(toLower.parse('HELLO'), equals('hello'));

  // 4) Trim
  final trimmed = z.string().trim();
  expect(trimmed.parse('  hello  '), equals('hello'));

  // 5) Normalize (remove acentos/diacríticos, trim, collapse whitespace)
  final normalized = z.string().normalize();
  // 'áéí' -> 'aei', ' e\n  outra ' -> 'e outra'
  expect(normalized.parse('  áéí  '), equals('aei'));
  expect(normalized.parse(' linha\n  final '), equals('linha final'));
}
```

Observações:

- Os métodos validators (uppercase/lowercase) apenas validam o estado atual do valor; se quiser transformar automaticamente, use toUpperCase()/toLowerCase().
- normalize() depende do package string_normalizer para remoção de acentos/diacríticos e aplica limpeza adicional descrita acima.

<br>

#### String → Boolean (stringbool)

Zard oferece um schema conveniente para interpretar strings como booleanos via `z.stringbool()`.
Ele aceita valores booleanos, numéricos e strings que representam estados verdadeiros ou falsos.

Tokens reconhecidos (case-insensitive, com trim):

- Verdadeiros: `1`, `true`, `yes`, `on`, `y`, `enabled`
- Falsos: `0`, `false`, `no`, `off`, `n`, `disabled`

Exemplos:

```dart
import 'package:zard/zard.dart';

void main() {
  final strbool = z.stringbool();

  // Valores que resultam em true
  print(strbool.parse('1')); // true
  print(strbool.parse('yes')); // true
  print(strbool.parse('ON')); // true
  print(strbool.parse(' enabled ')); // true (trim + case-insensitive)

  // Valores que resultam em false
  print(strbool.parse('0')); // false
  print(strbool.parse('no')); // false
  print(strbool.parse('Off')); // false
  print(strbool.parse('disabled')); // false

  // Também aceita bool e números
  print(strbool.parse(true)); // true
  print(strbool.parse(0)); // false

  // Valores não reconhecidos lançam ZardError
  // strbool.parse('maybe'); // throws ZardError
}
```

Observações:

- O método `parse()` retorna um `bool` quando a entrada é reconhecida; caso contrário lança `ZardError` com detalhes do problema.
- Se precisar de comportamento de coerção mais permissivo (por exemplo tratar qualquer valor não-vazio como `true`), use `z.coerce.boolean()`.

<br>

#### Advanced String Validators

Zard fornece uma série de validadores especializados para tipos comuns de strings (URLs, IPs, hashes, etc.):

**Identificadores e UUIDs:**

- `guid()` — GUID/UUID v4
- `uuid(version)` — UUID genérico (v1-v8) ou versão específica
- `nanoid()` — Nano ID (21 caracteres)
- `ulid()` — ULID (Universally Unique Lexicographically Sortable Identifier)

**Redes e Protocolos:**

- `httpUrl()` — URLs HTTP/HTTPS apenas
- `hostname()` — Hostname válido
- `ipv4()` — Endereço IPv4
- `ipv6()` — Endereço IPv6
- `mac()` — Endereço MAC (ex: `AA:BB:CC:DD:EE:FF`)
- `cidrv4()` — Bloco CIDR IPv4 (ex: `192.168.1.0/24`)
- `cidrv6()` — Bloco CIDR IPv6

**Codificações e Hashes:**

- `base64()` — Base64 padrão
- `base64url()` — Base64 URL-safe
- `hex()` — Hexadecimal
- `hash(algorithm)` — Hash validado por algoritmo (suporta `sha1`, `sha256`, `sha384`, `sha512`, `md5`)
- `jwt()` — JSON Web Token

**Outros Formatos:**

- `emoji()` — Um único caractere emoji

Exemplos:

```dart
import 'package:zard/zard.dart';

void main() {
  // UUIDs
  final guidSchema = z.string().guid();
  print(guidSchema.parse('550e8400-e29b-41d4-a716-446655440000')); // válido

  final uuidSchema = z.string().uuid(version: 'v4');
  print(uuidSchema.parse('550e8400-e29b-41d4-a716-446655440000')); // válido

  // Identificadores
  final nanoidSchema = z.string().nanoid();
  print(nanoidSchema.parse('V1StGXR_Z5j3eK4CFLQ')); // 21 caracteres

  final ulidSchema = z.string().ulid();
  print(ulidSchema.parse('01ARZ3NDEKTSV4RRFFQ69G5FAV')); // válido

  // URLs e Hosts
  final httpUrlSchema = z.string().httpUrl();
  print(httpUrlSchema.parse('https://example.com')); // válido

  final hostnameSchema = z.string().hostname();
  print(hostnameSchema.parse('api.example.com')); // válido

  // Redes
  final ipv4Schema = z.string().ipv4();
  print(ipv4Schema.parse('192.168.1.1')); // válido

  final ipv6Schema = z.string().ipv6();
  print(ipv6Schema.parse('2001:0db8:85a3:0000:0000:8a2e:0370:7334')); // válido

  final macSchema = z.string().mac();
  print(macSchema.parse('AA:BB:CC:DD:EE:FF')); // válido

  final cidrv4Schema = z.string().cidrv4();
  print(cidrv4Schema.parse('192.168.1.0/24')); // válido

  // Codificações
  final base64Schema = z.string().base64();
  print(base64Schema.parse('SGVsbG8gV29ybGQ=')); // válido

  final base64urlSchema = z.string().base64url();
  print(base64urlSchema.parse('SGVs-bG8tV29ybGQ')); // válido (URL-safe)

  final hexSchema = z.string().hex();
  print(hexSchema.parse('48656C6C6F')); // válido (paridade par)

  // Hashes
  final sha256Schema = z.string().hash('sha256');
  print(sha256Schema.parse('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855')); // válido

  final md5Schema = z.string().hash('md5');
  print(md5Schema.parse('5d41402abc4b2a76b9719d911017c592')); // válido

  // JWT
  final jwtSchema = z.string().jwt();
  print(jwtSchema.parse('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ')); // válido

  // Emoji
  final emojiSchema = z.string().emoji();
  print(emojiSchema.parse('😀')); // válido
}
```

<br>

#### ISO 8601 Date/Time Validators

Zard fornece validadores especializados para formatos ISO 8601, acessíveis via namespace `z.iso.*`:

- `z.iso.date()` — Data ISO (YYYY-MM-DD)
- `z.iso.time()` — Hora ISO (HH:mm:ss ou com milissegundos)
- `z.iso.datetime()` — Data e hora ISO 8601 (com ou sem Z)
- `z.iso.duration()` — Duração ISO 8601 (ex: P1DT2H3M4S)

Exemplos:

```dart
import 'package:zard/zard.dart';

void main() {
  // ISO Date
  final isoDateSchema = z.iso.date();
  print(isoDateSchema.parse('2021-01-01')); // válido
  // isoDateSchema.parse('01/01/2021'); // erro

  // ISO Time
  final isoTimeSchema = z.iso.time();
  print(isoTimeSchema.parse('12:30:45')); // válido
  print(isoTimeSchema.parse('12:30:45.123')); // válido (com milissegundos)

  // ISO DateTime
  final isoDatetimeSchema = z.iso.datetime();
  print(isoDatetimeSchema.parse('2021-01-01T12:30:45Z')); // válido
  print(isoDatetimeSchema.parse('2021-01-01T12:30:45')); // válido

  // ISO Duration
  final isoDurationSchema = z.iso.duration();
  print(isoDurationSchema.parse('P1Y2M3DT4H5M6S')); // 1 ano, 2 meses, 3 dias, 4h, 5m, 6s
  print(isoDurationSchema.parse('P1D')); // 1 dia
  print(isoDurationSchema.parse('PT5H')); // 5 horas
  print(isoDurationSchema.parse('P1W')); // 1 semana
}
```

Formatos ISO 8601 Duration:

- `P` = período
- `Y` = years
- `M` = months (antes de `T`) ou minutes (após `T`)
- `W` = weeks
- `D` = days
- `T` = separador (hora/minutos/segundos)
- `H` = hours
- `S` = seconds

Exemplos válidos: `P3Y`, `P2M`, `P1W`, `P1D`, `PT1H`, `PT30M`, `PT45S`, `P1DT2H30M`

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
    print("Safe Parsed Value: ${safeResult.data}');
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
