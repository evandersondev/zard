import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:zard/zard.dart';

/// Canonical Zard benchmark suite, using package:benchmark_harness.
/// Each scenario is a `BenchmarkBase` subclass: setup runs once, run() is timed.
/// The harness auto-calibrates (~2s per benchmark) and reports microseconds/op.
///
/// Run with:
///   dart run test/src/benchmarks/zard_harness_benchmark.dart        # JIT
///   dart compile exe test/src/benchmarks/zard_harness_benchmark.dart -o /tmp/zb && /tmp/zb   # AOT

class StringValid extends BenchmarkBase {
  StringValid() : super('Zard - String valid');
  final schema = z.string().min(3);
  @override
  void run() => schema.parse('hello');
}

class StringInvalid extends BenchmarkBase {
  StringInvalid() : super('Zard - String invalid');
  final schema = z.string().min(10);
  @override
  void run() {
    try {
      schema.parse('hi');
    } catch (_) {}
  }
}

class SmallObject extends BenchmarkBase {
  SmallObject() : super('Zard - Small object');
  final schema = z.map({
    'name': z.string(),
    'age': z.int(),
  });
  final data = const {'name': 'John', 'age': 30};
  @override
  void run() => schema.parse(data);
}

class MediumObject extends BenchmarkBase {
  MediumObject() : super('Zard - Medium object');
  final schema = z.map({
    'name': z.string(),
    'email': z.string().email(),
    'age': z.int().min(18),
    'active': z.bool(),
    'tags': z.list(z.string()),
  });
  final data = const {
    'name': 'John',
    'email': 'john@example.com',
    'age': 30,
    'active': true,
    'tags': ['dart', 'flutter'],
  };
  @override
  void run() => schema.parse(data);
}

class ComplexObject extends BenchmarkBase {
  ComplexObject() : super('Zard - Complex object');
  final schema = z.map({
    'user': z.map({
      'name': z.string(),
      'email': z.string().email(),
      'age': z.int(),
    }),
    'orders': z.list(z.map({
      'id': z.string(),
      'price': z.double(),
      'quantity': z.int(),
    })),
  });
  final data = {
    'user': {'name': 'John', 'email': 'john@example.com', 'age': 30},
    'orders': List.generate(
        5, (i) => {'id': '$i', 'price': 10.5, 'quantity': 2}),
  };
  @override
  void run() => schema.parse(data);
}

class TransformBench extends BenchmarkBase {
  TransformBench() : super('Zard - Transform');
  final schema = z.string().transform((v) => v.toUpperCase());
  @override
  void run() => schema.parse('hello');
}

class DefaultBench extends BenchmarkBase {
  DefaultBench() : super('Zard - Default');
  final schema = z.int().$default(10);
  @override
  void run() => schema.parse(null);
}

class NullableBench extends BenchmarkBase {
  NullableBench() : super('Zard - Nullable');
  final schema = z.string().nullable();
  @override
  void run() => schema.parse(null);
}

class UnionStringBench extends BenchmarkBase {
  UnionStringBench() : super('Zard - Union (string)');
  final schema = z.union([z.string(), z.int()]);
  @override
  void run() => schema.parse('hello');
}

class UnionIntBench extends BenchmarkBase {
  UnionIntBench() : super('Zard - Union (int)');
  final schema = z.union([z.string(), z.int()]);
  @override
  void run() => schema.parse(10);
}

class SafeParseBench extends BenchmarkBase {
  SafeParseBench() : super('Zard - safeParse');
  final schema = z.map({'name': z.string(), 'age': z.int()});
  final data = const {'name': 'John', 'age': 30};
  @override
  void run() => schema.safeParse(data);
}

void main() {
  final benchmarks = <BenchmarkBase>[
    StringValid(),
    StringInvalid(),
    SmallObject(),
    MediumObject(),
    ComplexObject(),
    TransformBench(),
    DefaultBench(),
    NullableBench(),
    UnionStringBench(),
    UnionIntBench(),
    SafeParseBench(),
  ];

  for (final b in benchmarks) {
    // BenchmarkBase.measure returns microseconds per op.
    final usPerOp = b.measure();
    final opsPerSec = (1000000 / usPerOp).round();
    print('📊 ${b.name}');
    print('Per op: ${usPerOp.toStringAsFixed(4)} µs');
    print('Ops/sec: $opsPerSec');
    print('');
  }
}
