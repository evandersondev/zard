import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  group('Zard Benchmark', () {
    const iterations = 100000;

    void benchmark(String name, void Function() fn) {
      final sw = Stopwatch()..start();
      fn();
      sw.stop();

      final perOp = sw.elapsedMicroseconds / iterations;

      print('''
📊 $name
Total: ${sw.elapsedMilliseconds} ms
Per op: ${perOp.toStringAsFixed(4)} µs
Ops/sec: ${(1000000 / perOp).toStringAsFixed(0)}
''');
    }

    test('Primitive parsing', () {
      final schema = z.string().min(3);

      benchmark('String parse (valid)', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse('hello');
        }
      });
    });

    test('Primitive parsing with error', () {
      final schema = z.string().min(10);

      benchmark('String parse (invalid)', () {
        for (var i = 0; i < iterations; i++) {
          try {
            schema.parse('hi');
          } catch (_) {}
        }
      });
    });

    test('SafeParse vs Parse', () {
      final schema = z.int().min(0);

      benchmark('parse()', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(10);
        }
      });

      benchmark('safeParse()', () {
        for (var i = 0; i < iterations; i++) {
          schema.safeParse(10);
        }
      });
    });

    test('Object small', () {
      final schema = z.map({
        'name': z.string(),
        'age': z.int(),
      });

      final data = {
        'name': 'John',
        'age': 30,
      };

      benchmark('Small object', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(data);
        }
      });
    });

    test('Object medium', () {
      final schema = z.map({
        'name': z.string(),
        'email': z.string().email(),
        'age': z.int().min(18),
        'active': z.bool(),
        'tags': z.list(z.string()),
      });

      final data = {
        'name': 'John',
        'email': 'john@example.com',
        'age': 30,
        'active': true,
        'tags': ['dart', 'flutter'],
      };

      benchmark('Medium object', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(data);
        }
      });
    });

    test('Object complex nested', () {
      final schema = z.map({
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

      benchmark('Complex object', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(data);
        }
      });
    });

    test('Transform cost', () {
      final schema = z.string().transform((v) => v.toUpperCase());

      benchmark('With transform', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse('hello');
        }
      });
    });

    test('Default + optional cost', () {
      final schema = z.int().$default(10);

      benchmark('Default handling', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(null);
        }
      });
    });

    test('Nullable cost', () {
      final schema = z.bool().nullable();

      benchmark('Nullable', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(null);
        }
      });
    });

    test('Union cost', () {
      final schema = z.union([
        z.string(),
        z.int(),
      ]);

      benchmark('Union (string)', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse('hello');
        }
      });

      benchmark('Union (int)', () {
        for (var i = 0; i < iterations; i++) {
          schema.parse(10);
        }
      });
    });
  });
}
