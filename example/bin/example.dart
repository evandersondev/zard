import 'package:zard/zard.dart';

void main() {
  final stringSchema = z.string().min(3);
  final hello = stringSchema.parse('hello');
  print(hello);
  // Output: hello

  // Example usage:
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

  final userData = {
    'name': 'John Doe',
    'age': 30,
    'sallary': 5000.0,
    'email': 'john.doe@example.com',
    'tags': ['developer', 'dart', 'flutter'],
    'addresses': [
      {'street': '123 Main St', 'city': 'Springfield'},
      {'street': '456 Elm St', 'city': 'Shelbyville'},
    ],
  };

  final user = userSchema.parse(userData);
  print(user);
  print(userSchema.getErrors());
  // Output:
  // {
  //   'name': 'JOHN DOE',
  //   'age': 30,
  //   'email': 'john.doe@example.com',
  //   'tags': ['#developer
  //   , '#dart', '#flutter'],
  //   'addresses': [
  //     {'street': '123 Main St', 'city': 'SPRINGFIELD'},
  //     {'street': '456 Elm St', 'city': 'SHELBYVILLE'},
  //   ],
  // }

  final dateSchema = z.date();
  final date = dateSchema.parse(DateTime.now());
  print(date);
  print(dateSchema.getErrors());
  // Output: 2013-07-25

  final enumSchema = z.enumerate(['red', 'green', 'blue']).exclude(['green']);

  final roles = ['red', 'green', 'blue'];

  final result = enumSchema.parse(roles);

  print('Extract and exclude enum values: $result');
  final enumValue = enumSchema.parse(['red']);
  print(enumSchema.getErrors());
  print(enumValue);
  // Output: ['red']

  final tweetSchema = z.map({
    'title': z.string().min(3),
    'author': z.string().min(3),
  });

  final tweet = tweetSchema.parse({
    'title': 'Hello World',
    'author': 'John Doe',
    'content': 'This is a tweet', // ignored
    'comments': [
      // ignored
      {'author': 'Jane Doe', 'content': 'Great tweet!'}, // ignored
      {'author': 'John Doe', 'content': 'Thanks!'}, // ignored
    ],
  });

  print(tweet);

  final listSchema = z.list(z.string()).noempty();
  final list = listSchema.parse(['a', 'b']);
  print(list);
}
