import 'package:zard/zard.dart';

const iterations = 100000;

void benchmark(String name, void Function() fn) {
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    fn();
  }

  stopwatch.stop();

  final totalMs = stopwatch.elapsedMilliseconds;
  final totalUs = stopwatch.elapsedMicroseconds;
  final perOp = totalUs / iterations;
  final opsPerSec = (1000000 / perOp);

  print('''
📊 $name
Total: ${totalMs} ms
Per op: ${perOp.toStringAsFixed(4)} µs
Ops/sec: ${opsPerSec.toStringAsFixed(0)}
''');
}

void main() {
  // -----------------------------
  // Primitive (equivalente Zod)
  // -----------------------------
  final stringSchema = z.string().min(3);

  benchmark("Zard - String valid", () {
    stringSchema.parse("hello");
  });

  // -----------------------------
  // Small object
  // -----------------------------
  final objectSchema = z.map({
    'name': z.string(),
    'age': z.int(),
  });

  benchmark("Zard - Small object", () {
    objectSchema.parse({
      'name': 'John',
      'age': 30,
    });
  });

  // -----------------------------
  // Complex object
  // -----------------------------
  final complexSchema = z.map({
    'user': z.map({
      'name': z.string(),
      'email': z.string().email(),
      'age': z.int(),
    }),
    'orders': z.list(
      z.map({
        'id': z.string(),
        'price': z.double(),
        'quantity': z.int(),
      }),
    ),
  });

  final data = {
    'user': {
      'name': 'John',
      'email': 'john@example.com',
      'age': 30,
    },
    'orders': List.generate(5, (i) {
      return {
        'id': '$i',
        'price': 10.5,
        'quantity': 2,
      };
    }),
  };

  benchmark("Zard - Complex object", () {
    complexSchema.parse(data);
  });

  // -----------------------------
  // Extra: safeParse (vantagem do Zard)
  // -----------------------------
  benchmark("Zard - safeParse", () {
    objectSchema.safeParse({
      'name': 'John',
      'age': 30,
    });
  });

  // -----------------------------
  // Extra: Union
  // -----------------------------
  final unionSchema = z.union([
    z.string(),
    z.int(),
  ]);

  benchmark("Zard - Union (string)", () {
    unionSchema.parse("hello");
  });

  benchmark("Zard - Union (int)", () {
    unionSchema.parse(123);
  });

  // -----------------------------
  // Extra: Default
  // -----------------------------
  final defaultSchema = z.int().$default(10);

  benchmark("Zard - Default", () {
    defaultSchema.parse(null);
  });

  // -----------------------------
  // Extra: Nullable
  // -----------------------------
  final nullableSchema = z.string().nullable();

  benchmark("Zard - Nullable", () {
    nullableSchema.parse(null);
  });
}
