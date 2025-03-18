import 'package:zard/zard.dart';

void main() {
  final stringSchema = z.string().min(3);
  final hello = stringSchema.parse('hello');
  print(hello);

  final intSchema = z.int().min(0).max(10);
  final age = intSchema.parse(5);
  print(age);

  final doubleSchema = z.double().min(0).max(10);
  final sallary = doubleSchema.parse(5.5);
  print(sallary);

  final emailSchema = z.string().email();
  final email = emailSchema.parse('john.doe@example.com');
  print(email);

  final tagsSchema = z.list(z.string().transform((value) => '#$value'));
  final tags = tagsSchema.parse(['#dart', '#flutter']);
  print(tags);

  final birthdaySchema = z.date().optional();
  final birthday = birthdaySchema.parse(DateTime.now());
  print(birthday);

  final addressesSchema = z.list(
    z.map({
      'street': z.string(),
      'city': z.string().transform((value) => value.toUpperCase()),
    }),
  );
  final addresses = addressesSchema.parse([
    {'street': '123 Main St', 'city': 'SPRINGFIELD'},
    {'street': '456 Elm St', 'city': 'SHELBYVILLE'},
  ]);
  print(addresses);

  final enumSchema = z.enumerate(['red', 'green', 'blue']).exclude(['green']);
  final roles = ['red', 'green', 'blue'];
  final result = enumSchema.parse(roles);
  print('Extract and exclude enum values: $result');

  final userSchema = z.map({
    'name': z.string().transform((value) => value.toUpperCase()),
    'age': z.int(),
    'sallary': z.double(),
    'email': z.string().email(message: 'Deve ser um email válido'),
    'tags': z.list(z.string().transform((value) => '#$value')),
    'birthday': z.date().optional(),
    'addresses': z.list(
      z.map({
        'street': z.string(),
        'city': z.string().transform((value) => value.toUpperCase()),
      }),
    ),
  });
  final user = userSchema.parse({
    'name': 'John Doe',
    'age': 30,
    'sallary': 5000.0,
    'email': 'john.doe@example.com',
    'tags': ['#dart', '#flutter'],
    'birthday': DateTime.now(),
    'addresses': [
      {'street': '123 Main St', 'city': 'SPRINGFIELD'},
      {'street': '456 Elm St', 'city': 'SHELBYVILLE'},
    ],
  });
  print(user);

  final ignoreSchema = z.map({
    'name': z.string().min(3),
    'age': z.int().min(18).nullable(),
    'email': z.string().email(),
  });

  final ignore = ignoreSchema.parse({
    'name': 'John Doe',
    'age': 30,
    'email': 'john.doe@example.com',
    'address': '123 Main St', // ignored
  });
  print(ignore);

  print(ignoreSchema.keyof());
  print(ignoreSchema.pick(['name']));
  print(ignoreSchema.omit(['age']));

  final boolSchema = z.bool().nullable();
  final bool = boolSchema.parse(null);
  print(bool);

  final ifNullValue = ignoreSchema.parse({
    'name': 'John Doe',
    'age': null,
    'email': 'john.doe@example.com',
  });
  print(ifNullValue);
}
