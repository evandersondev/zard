import 'package:zard/zard.dart';

const iterations = 100000;

void benchmark(String name, void Function() fn) {
  // Warm-up: a few thousand iterations to let the JIT/AOT optimizer settle
  // before we start timing. Without warmup, the first ~1k iterations dominate
  // the average and produce misleading numbers.
  for (int i = 0; i < 5000; i++) {
    fn();
  }

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
  // Primitive valid
  // -----------------------------
  final stringSchema = z.string().min(3);
  benchmark("Zard - String valid", () {
    stringSchema.parse("hello");
  });

  // -----------------------------
  // Primitive invalid (with try/catch — matches Zod's pattern)
  // -----------------------------
  final invalidSchema = z.string().min(10);
  benchmark("Zard - String invalid", () {
    try {
      invalidSchema.parse("hi");
    } catch (_) {}
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
  // Medium object
  // -----------------------------
  final mediumSchema = z.map({
    'name': z.string(),
    'email': z.string().email(),
    'age': z.int().min(18),
    'active': z.bool(),
    'tags': z.list(z.string()),
  });
  benchmark("Zard - Medium object", () {
    mediumSchema.parse({
      'name': 'John',
      'email': 'john@example.com',
      'age': 30,
      'active': true,
      'tags': ['dart', 'flutter'],
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
  // Transform
  // -----------------------------
  final transformSchema = z.string().transform((v) => v.toUpperCase());
  benchmark("Zard - Transform", () {
    transformSchema.parse('hello');
  });

  // -----------------------------
  // Default
  // -----------------------------
  final defaultSchema = z.int().$default(10);
  benchmark("Zard - Default", () {
    defaultSchema.parse(null);
  });

  // -----------------------------
  // Nullable
  // -----------------------------
  final nullableSchema = z.string().nullable();
  benchmark("Zard - Nullable", () {
    nullableSchema.parse(null);
  });

  // -----------------------------
  // Union
  // -----------------------------
  final unionSchema = z.union([
    z.string(),
    z.int(),
  ]);

  benchmark("Zard - Union (string)", () {
    unionSchema.parse("hello");
  });

  benchmark("Zard - Union (int)", () {
    unionSchema.parse(10);
  });

  // -----------------------------
  // safeParse
  // -----------------------------
  benchmark("Zard - safeParse", () {
    objectSchema.safeParse({'name': 'John', 'age': 30});
  });
}
