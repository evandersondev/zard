// Error handling: flattenError, treeifyError, prettifyError, unwrap,
// unwrapOrNull, when, and firstErrors.
import 'package:zard/zard.dart';

void main() {
  final userSchema = z.map({
    'name': z.string().min(2),
    'email': z.string().email(),
    'age': z.int().min(0),
  });

  // Produce a failed parse with multiple field errors.
  final result = userSchema.safeParse({
    'name': 'A', // too short
    'email': 'not-valid',
    'age': -5,
  });

  print('success: ${result.success}'); // false

  // --- unwrap(): throws on failure ---
  try {
    result.unwrap();
  } on ZardError catch (e) {
    print('unwrap threw: ${e.issues.length} issues');
  }

  // --- unwrapOrNull(): returns null on failure ---
  print(result.unwrapOrNull()); // null

  // --- when(): pattern-match on success/failure ---
  result.when(
    success: (data) => print('got data: $data'),
    error: (err) => print('got ${err.issues.length} errors'),
  );

  // --- flattenError(): collapse to {formErrors, fieldErrors} ---
  final flattened = z.flattenError(result.error!);
  print('formErrors: ${flattened.formErrors}');
  print('fieldErrors: ${flattened.fieldErrors}');

  // --- firstErrors: one message per field (handy for form hints) ---
  print('firstErrors: ${flattened.firstErrors}');

  // --- treeifyError(): nested tree structure ---
  final tree = z.treeifyError(result.error!);
  print('tree.properties keys: ${tree.properties?.keys.toList()}');
  print('name errors: ${tree.properties?["name"]?.errors}');

  // --- prettifyError(): human-readable multi-line string ---
  print(z.prettifyError(result.error!));

  // --- Successful result ---
  final ok = userSchema.safeParse({
    'name': 'Alice',
    'email': 'alice@example.com',
    'age': 30,
  });
  print(ok.unwrap()); // {name: Alice, email: alice@example.com, age: 30}
  print(ok.unwrapOrNull()); // same
  ok.when(
    success: (data) => print('name: ${data["name"]}'),
    error: (_) => print('failed'),
  );
}
