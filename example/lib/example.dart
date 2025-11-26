import 'package:intl/intl.dart';
import 'package:zard/zard.dart';

import 'user.dart';

String slugify(String str) {
  final slug = str
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+'), '')
      .replaceAll(RegExp(r'-+$'), '');
  return slug;
}

void main() async {
  print(z.int().$default(42).parse(null)); // Output: 42
  print(z.string().$default('Hello World').parse(null)); // Output: Hello World
  print(z.double().$default(3.14).parse(null)); // Output: 3.14
  print(z.bool().$default(true).parse(null)); // Output: true
  // example with map schema
  final pedidoSchema = z.map({
    'numero_pedido': z.string(),
    'status': z.$enum([
      'pendente',
      'processando',
      'enviado',
      'entregue',
      'cancelado'
    ]).$default('pendente'),
    'produto': z.map({
      'id': z.string(),
      'nome': z.string().min(3).max(50),
      'preco': z.double().min(0),
      'quantidade': z.int().min(1).$default(20),
    }),
  });
  final pedido = pedidoSchema.parse({
    'numero_pedido': '123456',
    'produto': {
      'id': '123',
      'nome': 'Produto Exemplo',
      'preco': 10.99,
    }
  });
  print(pedido);

  final product = {
    'quantity': 4,
    'price': 1500.0,
    'currency': 'usd',
    'name': 'MacBook Pro',
  };

  final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final schema = z.map({
    'quantity': z.int(),
    'price': z.double().transform((p) => f.format(p)),
    'currency': z.string().transform((c) => c.toUpperCase()),
    'name': z.string(),
  }).transform((map) {
    map['slug'] = slugify(map['name']);
    map['total'] = map['quantity'] * f.parse(map['price']);
    return map;
  });

  final result = schema.parse(product);
  print(result);

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
  final enumSchema = z.$enum(['red', 'green', 'blue']).extract(['red', 'blue']);
  // final roles = ['red', 'green', 'blue'];
  final result2 = enumSchema.parse('red');
  print('Enum values: $result2');
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
  final userSchema = z.inferType(
    fromMap: (json) => User.fromMap(json),
    mapSchema: z.map({
      'name': z.string().min(3),
      'email': z.string().email(),
      'friends': z
          .list(z.map({
            'name': z.string().min(3),
            'email': z.string().email(),
            'friends': z
                .list(z.map({
                  'name': z.string().min(3),
                  'email': z.string().email(),
                }))
                .optional(),
          }))
          .optional(),
    }),
  );

  try {
    final user = userSchema.parse({
      'name': 'John Doe',
      'email': 'john.doe@example.com',
    });
    print('User created: ${user.name}, ${user.email}');
  } on ZardError catch (e) {
    print('Error: ${e.messages}');
  }

  // if (ignore.success) {
  //   print(ignore.data);
  // } else {
  //   print(ignore.error);
  // }

  final ignoreSchema = z.map({
    'name': z.string().min(3).max(20),
    'age': z.int().min(18).max(80).nullable(),
    'email': z.string().email(),
    'isActive': z.bool().optional(),
  });

  final ignore = ignoreSchema.safeParse({
    'name': 'John Doe',
    'age': 50,
    'email': 'john.doe@example.com',
    'isActive': true,
  });
  if (ignore.success) {
    print(ignore.data);
  } else {
    print(ignore.error?.issues.toList());
  }
  // final stringSchema = z.string().min(3);
  // final hello = stringSchema.parse('lo');
  // print(hello);

  final intSchema = z.int().min(0).max(10);
  final age = intSchema.safeParse(5);
  print(age);

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
