import 'package:zard/zard.dart';

String slugify(String str) {
  final slug = str
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+'), '')
      .replaceAll(RegExp(r'-+$'), '');
  return slug;
}

void main() async {
  final isoDateSchema = z.iso.date();
  final isoTimeSchema = z.iso.time();
  final isoDatetimeSchema = z.iso.datetime();
  final isoDurationSchema = z.iso.duration();

// Exemplos de uso
  print(isoDateSchema.parse('2021-01-01')); // válido
  print(isoTimeSchema.parse('12:30:45')); // válido
  print(isoDatetimeSchema.parse('2021-01-01T12:30:45Z')); // válido
  print(isoDurationSchema.parse('P1DT2H3M4S'));

  // final string = z.stringbool();
  // print(string.parse('1'));

  // final uppercaseSchema = z.string().uppercase();
  // print(uppercaseSchema.parse('ZARD'));

  // final lowercaseSchema = z.string().lowercase();
  // print(lowercaseSchema.parse('zard'));

  // final trimSchema = z.string().trim();
  // print(trimSchema.parse('   zard-trim   '));

  // final toUppercaseSchema = z.string().toUpperCase();
  // print(toUppercaseSchema.parse('zard to uppercase'));

  // final toLowercaseSchema = z.string().toLowerCase();
  // print(toLowercaseSchema.parse('ZARD TO LOWERCASE'));

  // final normalizeSchema = z.string().normalize();
  // print(normalizeSchema.parse('Café com açúcar'));

  // final html5 = z.string().email(pattern: z.regexes.html5Email);
  // print('html5 -> OK: ${html5.parse('john@example')}');

  // final strict = z.string().email(pattern: z.regexes.email);
  // print('strict -> OK: ${strict.parse('john@example.com')}');

  // final rfc = z.string().email(pattern: z.regexes.rfc5322Email);
  // print('rfc5322 -> OK: ${rfc.parse('john.doe+tag@example.co.uk')}');

  // final uni = z.string().email(pattern: z.regexes.unicodeEmail);
  // print('unicode -> OK: ${uni.parse('usuário@exemplo.com')}');

  // // Uuid examples
  // // Generic (any valid version 1-8)
  // final uuidAny = z.string().uuid();
  // print(
  //     'UUID (any version) -> OK: ${uuidAny.parse('f47ac10b-58cc-5372-a167-0f8c6a8b54c0')}');

  // // Explicit versions (use 'v1' .. 'v8')
  // final uuidV1 = z.string().uuid(version: 'v1');
  // print(
  //     'UUID v1 -> OK: ${uuidV1.parse('6ba7b810-9dad-11d1-80b4-00c04fd430c8')}');

  // final uuidV2 = z.string().uuid(version: 'v2');
  // print(
  //     'UUID v2 -> OK: ${uuidV2.parse('123e4567-e89b-21d3-a456-426614174000')}');

  // final uuidV3 = z.string().uuid(version: 'v3');
  // print(
  //     'UUID v3 -> OK: ${uuidV3.parse('f47ac10b-58cc-3372-a167-0f8c6a8b54c0')}');

  // final uuidV4 = z.string().uuid(version: 'v4');
  // print(
  //     'UUID v4 -> OK: ${uuidV4.parse('550e8400-e29b-41d4-a716-446655440000')}');

  // final uuidV5 = z.string().uuid(version: 'v5');
  // print(
  //     'UUID v5 -> OK: ${uuidV5.parse('f47ac10b-58cc-5372-a167-0f8c6a8b54c0')}');

  // final uuidV6 = z.string().uuid(version: 'v6');
  // print(
  //     'UUID v6 -> OK: ${uuidV6.parse('123e4567-e89b-61d3-a456-426614174000')}');

  // final uuidV7 = z.string().uuid(version: 'v7');
  // print(
  //     'UUID v7 -> OK: ${uuidV7.parse('123e4567-e89b-71d3-a456-426614174000')}');

  // final uuidV8 = z.string().uuid(version: 'v8');
  // print(
  //     'UUID v8 -> OK: ${uuidV8.parse('123e4567-e89b-81d3-a456-426614174000')}');

  // Padrão (aceita http(s) opcional e host genérico):
  // final urlSchema = z.string().url();
  // print(urlSchema.parse('https://www.example.com'));
  // // OK schema.parse('www.example.com');
  // // OK (protocol opcional) schema.parse('notaurl'); // lança erro

  // // Forçar hostname que termine com .example.com:
  // final urlWithHostnameSchema =
  //     z.string().url(hostname: RegExp(r'^[\w\.-]+\.example\.com$'));
  // print(urlWithHostnameSchema.parse('https://api.example.com/path'));
  // // OK schema.parse('https://other.com'); // lança erro

  // // Forçar protocolo (ex.: somente https):
  // final urlProtocolSchema = z.string().url(protocol: RegExp(r'^https:\/\/'));
  // print(urlProtocolSchema.parse('https://secure.example.com'));
  // // OK schema.parse('http://insecure.example.com'); // lança erro

  // // Usando hostname + protocolo personalizados:
  // final urlAllSchema = z.string().url(
  //       hostname: RegExp(r'^[\w\.-]+\.example\.com$'),
  //       protocol: RegExp(r'^https:\/\/'),
  //     );
  // print(urlAllSchema.parse('https://api.example.com/endpoint'));
  // OK schema.parse('http://api.example.com/endpoint'); // lança erro

  // print(z.int().$default(42).parse(null)); // Output: 42
  // print(z.string().$default('Hello World').parse(null)); // Output: Hello World
  // print(z.double().$default(3.14).parse(null)); // Output: 3.14
  // print(z.bool().$default(true).parse(null)); // Output: true
  // example with map schema
  // final pedidoSchema = z.map({
  //   'numero_pedido': z.string(),
  //   'status': z.$enum([
  //     'pendente',
  //     'processando',
  //     'enviado',
  //     'entregue',
  //     'cancelado'
  //   ]).$default('pendente'),
  //   'produto': z.map({
  //     'id': z.string(),
  //     'nome': z.string().min(3).max(50),
  //     'preco': z.double().min(0),
  //     'quantidade': z.int().min(1).$default(20),
  //   }),
  // });
  // final pedido = pedidoSchema.parse({
  //   'numero_pedido': '123456',
  //   'produto': {
  //     'id': '123',
  //     'nome': 'Produto Exemplo',
  //     'preco': 10.99,
  //   }
  // });
  // print(pedido);

  // final product = {
  //   'quantity': 4,
  //   'price': 1500.0,
  //   'currency': 'usd',
  //   'name': 'MacBook Pro',
  // };

  // final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  // final schema = z.map({
  //   'quantity': z.int(),
  //   'price': z.double().transform((p) => f.format(p)),
  //   'currency': z.string().transform((c) => c.toUpperCase()),
  //   'name': z.string(),
  // }).transform((map) {
  //   map['slug'] = slugify(map['name']);
  //   map['total'] = map['quantity'] * f.parse(map['price']);
  //   return map;
  // });

  // final result = schema.parse(product);
  // print(result);

  // final pedidoMap = {
  //   'numero_pedido': '123456',
  //   'status': 'cancelado',
  //   'produto': {
  //     'id': '123',
  //     'nome': 'P',
  //     'preco': 10.99,
  //     'quantidade': -2,
  //   }
  // };
  // final pedido = pedidoSchema.parse(pedidoMap);
  // print(pedido);
  // final enumSchema = z.$enum(['red', 'green', 'blue']).extract(['red', 'blue']);
  // // final roles = ['red', 'green', 'blue'];
  // final result2 = enumSchema.parse('red');
  // print('Enum values: $result2');
  // mapsHelper();

  // final file = File('mock_file.txt');
  // await file.writeAsString('This is a mock file for testing purposes.');

  // final fileSchema = z.file().mime('image/png');
  // fileSchema.min(10000); // minimum size (bytes)
  /// fileSchema.max(1_000_000); // maximum size (bytes)
  /// fileSchema.mime("image/png"); // MIME type
  /// fileSchema.mime(["image/png", "image/jpeg"]);
  // print(fileSchema.parse(file));

  // Recursive schema example
  // Transform to type
  // Lazy schema
  // Schema<User> getUserSchema() {
  //   return z.interface({
  //     'name': z.string().min(3).max(20),
  //     'email': z.string().email(),
  //     'friends?': z.lazy(() => getUserSchema().list()),
  //   }).transformTyped((json) => User.fromMap(json));
  // }

  // final user = getUserSchema().parse({
  //   'name': 'John Doe',
  //   'email': 'john.doe@example.com',
  //   'friends': [
  //     {
  //       'name': 'Jane Doe',
  //       'email': 'jane.doe@example.com',
  //       'friends': [
  //         {
  //           'name': 'Evan Doe',
  //           'email': 'john.doe@example.com',
  //         },
  //       ],
  //     },
  //   ],
  // });
  // print(user?.friends.first.friends.first.name);
  // print(user.friends.first.friends.first.name);

  // final userSchemaInterface = z.interface({
  //   'name': z.string().min(3).max(20),
  //   'email': z.string().email(),
  //   'age?': z.int().min(18).max(80),
  //   'isActive?': z.bool(),
  // }).transformTyped((data) => User.fromMap(data));

  // final user = userSchemaInterface.parse({
  //   'name': 'John Doe',
  //   'email': 'john.doe@example.com',
  // });
  // print(user.email);

  // Inferred type example
  // final userSchema = z.inferType(
  //   fromMap: (json) => User.fromMap(json),
  //   mapSchema: z.map({
  //     'name': z.string().min(3),
  //     'email': z.string().email(),
  //     'friends': z
  //         .list(z.map({
  //           'name': z.string().min(3),
  //           'email': z.string().email(),
  //           'friends': z
  //               .list(z.map({
  //                 'name': z.string().min(3),
  //                 'email': z.string().email(),
  //               }))
  //               .optional(),
  //         }))
  //         .optional(),
  //   }),
  // );

  // try {
  //   final user = userSchema.parse({
  //     'name': 'John Doe',
  //     'email': 'john.doe@example.com',
  //   });
  //   print('User created: ${user.name}, ${user.email}');
  // } on ZardError catch (e) {
  //   print('Error: ${e.messages}');
  // }

  // if (ignore.success) {
  //   print(ignore.data);
  // } else {
  //   print(ignore.error);
  // }

  // final ignoreSchema = z.map({
  //   'name': z.string().min(3).max(20),
  //   'age': z.int().min(18).max(80).nullable(),
  //   'email': z.string().email(),
  //   'isActive': z.bool().optional(),
  // });

  // final ignore = ignoreSchema.safeParse({
  //   'name': 'John Doe',
  //   'age': 50,
  //   'email': 'john.doe@example.com',
  //   'isActive': true,
  // });
  // if (ignore.success) {
  //   print(ignore.data);
  // } else {
  //   print(ignore.error?.issues.toList());
  // }
  // final stringSchema = z.string().min(3);
  // final hello = stringSchema.parse('lo');
  // print(hello);

  // final intSchema = z.int().min(0).max(10);
  // final age = intSchema.safeParse(5);
  // print(age);

  // final doubleSchema = z.double(message: 'Deve ser um double').min(0).max(10);
  // final sallary = doubleSchema.parse('3');
  // print(sallary);

  // final emailSchema = z.string(message: 'Deve ser uma string').email();
  // final email = emailSchema.parse(2);
  // print(email);

  // final tagsSchema = z.list(z.string().transform((value) => '#$value'));
  // final tags = tagsSchema.parse(['#dart', '#flutter']);
  // print(tags);

  // final birthdaySchema = z.date().optional();
  // final birthday = birthdaySchema.parse(DateTime.now());
  // print(birthday);

  // final addressesSchema = z.list(
  //   z.map({
  //     'street': z.string(),
  //     'city': z.string().transform((value) => value.toUpperCase()),
  //   }),
  // );
  // final addresses = addressesSchema.parse([
  //   {'street': '123 Main St', 'city': 'SPRINGFIELD'},
  //   {'street': '456 Elm St', 'city': 'SHELBYVILLE'},
  // ]);
  // print(addresses);

  // final userSchema = z.map({
  //   'name': z.string().transform((value) => value.toUpperCase()),
  //   'age': z.int(),
  //   'sallary': z.double(),
  //   'email': z.string().email(message: 'Deve ser um email válido'),
  //   'tags': z.list(z.string().transform((value) => '#$value')),
  //   'birthday': z.date().optional(),
  //   'addresses': z.list(
  //     z.map({
  //       'street': z.string(),
  //       'city': z.string().transform((value) => value.toUpperCase()),
  //     }),
  //   ),
  // });
  // final user = userSchema.parse({
  //   'name': 'John Doe',
  //   'age': 30,
  //   'sallary': 5000.0,
  //   'email': 'john.doe@example.com',
  //   'tags': ['#dart', '#flutter'],
  //   'birthday': DateTime.now(),
  //   'addresses': [
  //     {'street': '123 Main St', 'city': 'SPRINGFIELD'},
  //     {'street': '456 Elm St', 'city': 'SHELBYVILLE'},
  //   ],
  // });
  // print(user);

  // final ignoreSchema = z.map({
  //   'name': z.string().min(3),
  //   'age': z.int().min(18).nullable(),
  //   'email': z.string().email(),
  //   'isActive': z.bool().nullable(),
  // });

  // final ignore = ignoreSchema.parse({
  //   'name': 'John Doe',
  //   'age': 30,
  //   'email': 'john.doe@example.com',
  //   'address': '123 Main St', // ignored
  //   'isActive': true,
  // });
  // print(ignore);

  // print(ignoreSchema.keyof());
  // print(ignoreSchema.pick(['name']));
  // print(ignoreSchema.omit(['age']));

  // final boolSchema = z.bool().nullable();
  // final bool = boolSchema.parse(null);
  // print(bool);

  // final ifNullValue = ignoreSchema.parse({
  //   'name': 'John Doe',
  //   'age': null,
  //   'email': 'john.doe@example.com',
  // });
  // print(ifNullValue);

  // final age = z.coerce.double().parse("25");
  // final name = z.coerce.string().parse(123);
  // final active = z.coerce.boolean().parse("");
  // final amount = z.coerce.int().parse(1000);
  // final date = z.coerce.date().parse("2021-10-05");

  // print(age);
  // print(name);
  // print(active);
  // print(amount);
  // print(date);

  // final person = z.map({'name': z.string()}).strict();
  // final data = person.parse({'name': 'bob dylan', 'extraKey': 61});
  // print(data);

  //   final schema = z.list(
  //     z.map({
  //       'id': z.int(),
  //       'name': z.string(),
  //       'email': z.string().email(),
  //       'age': z.int(),
  //       'isActive': z.bool(),
  //       'address': z.map({
  //         'street': z.string(),
  //         'city': z.string(),
  //         'state': z.string(),
  //         'zip': z.string(),
  //       }),
  //       'phoneNumbers': z.list(z.map({'type': z.string(), 'number': z.string()})),
  //       'roles': z.list(z.string()),
  //       'birthday': z.date(),
  //       'createdAt': z.date(),
  //       'updatedAt': z.date(),
  //     }),
  //   );
  //   final result = await schema.parseAsync(returnListRequestBodyUser());
  //   print(result);
  // }

  // Future<List<Map<String, dynamic>>> returnListRequestBodyUser() async {
  //   return Future.value([
  //     {
  //       "id": 1,
  //       "name": "John Doe",
  //       "email": "john.doe@example.com",
  //       "age": 30,
  //       "isActive": true,
  //       "address": {
  //         "street": "123 Main St",
  //         "city": "Springfield",
  //         "state": "IL",
  //         "zip": "62701",
  //       },
  //       "phoneNumbers": [
  //         {"type": "home", "number": "555-1234"},
  //         {"type": "work", "number": "555-5678"},
  //       ],
  //       "roles": ["admin", "user"],
  //       "birthday": "1990-01-01",
  //       "createdAt": "2021-01-01T00:00:00.000Z",
  //       "updatedAt": "2021-01-01T00:00:00.000Z",
  //     },
  //   ]);

  // final schema = z.map({
  //   'name': z.string(),
  //   'age': z.int(),
  //   'email': z.string().email()
  // }).refine((value) {
  //   return value['age'] > 18;
  // }, message: 'Age must be greater than 18');

  // final result = schema.safeParse({
  //   'name': 'John Doe',
  //   'age': 20,
  //   'email': 'john.doe@example.com',
  // });
  // print(result);
  // final result2 = schema.safeParse({
  //   'name': 'John Doe',
  //   'age': 10,
  //   'email': 'john.doe@example.com',
  // });
  // print(result2);
}
