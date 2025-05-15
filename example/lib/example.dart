import 'package:example/user.dart';
import 'package:zard/zard.dart';

void main() async {
  // Recursive schema example
  // Transform to type
  // Lazy schema
  Schema<User> getUserSchema() {
    return z.interface({
      'name': z.string().min(3).max(20),
      'email': z.string().email(),
      'friends?': z.lazy(() => getUserSchema().list()),
    }).transformTyped((json) => User.fromMap(json));
  }

  final user = getUserSchema().parse({
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'friends': [
      {
        'name': 'Jane Doe',
        'email': 'jane.doe@example.com',
        'friends': [
          {
            'name': 'Evan Doe',
            'email': 'john.doe@example.com',
          },
        ],
      },
    ],
  });
  print(user?.friends.first.friends.first.name);

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
    print(ignore.error);
  }
  // final stringSchema = z.string().min(3);
  // final hello = stringSchema.parse('hello');
  // print(hello);

  // final intSchema = z.int().min(0).max(10);
  // final age = intSchema.parse(5);
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

  // final enumSchema = z.enumerate(['red', 'green', 'blue']).exclude(['green']);
  // final roles = ['red', 'green', 'blue'];
  // final result = enumSchema.parse(roles);
  // print('Extract and exclude enum values: $result');

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
