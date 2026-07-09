import 'package:test/test.dart';
import 'package:zard/zard.dart';

void main() {
  // ---------------------------------------------------------------------------
  group('discriminatedUnion', () {
    final shape = z.discriminatedUnion('type', [
      z.map({
        'type': z.$enum(['circle']),
        'radius': z.double(),
      }),
      z.map({
        'type': z.$enum(['square']),
        'side': z.double(),
      }),
    ]);

    test('dispatches to the matching variant (circle)', () {
      final result = shape.parse({'type': 'circle', 'radius': 2.0});
      expect(result['type'], 'circle');
      expect(result['radius'], 2.0);
    });

    test('dispatches to the matching variant (square)', () {
      final result = shape.parse({'type': 'square', 'side': 3.0});
      expect(result['type'], 'square');
      expect(result['side'], 3.0);
    });

    test('unknown discriminator value throws with precise error', () {
      try {
        shape.parse({'type': 'triangle', 'base': 1.0});
        fail('should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.length, 1);
        expect(e.issues.first.type, 'discriminated_union_error');
        expect(e.issues.first.value, 'triangle');
      }
    });

    test('invalid variant body reports the field issue', () {
      // Correct discriminator (circle) but wrong body type for radius.
      try {
        shape.parse({'type': 'circle', 'radius': 'not-a-number'});
        fail('should have thrown');
      } on ZardError catch (e) {
        expect(e.issues.any((i) => i.path == 'radius'), isTrue);
      }
    });

    test('non-map input throws type_error', () {
      expect(() => shape.parse('nope'), throwsA(isA<ZardError>()));
      final res = shape.safeParse(42);
      expect(res.success, isFalse);
      expect(res.error!.issues.first.type, 'type_error');
    });

    test('null input throws required_error', () {
      final res = shape.safeParse(null);
      expect(res.success, isFalse);
      expect(res.error!.issues.first.type, 'required_error');
    });

    test('works nested inside a z.map (parseInto path)', () {
      final schema = z.map({
        'payload': shape,
      });
      final ok = schema.parse({
        'payload': {'type': 'square', 'side': 5.0}
      });
      expect(ok['payload']['side'], 5.0);

      final bad = schema.safeParse({
        'payload': {'type': 'hexagon'}
      });
      expect(bad.success, isFalse);
      expect(
        bad.error!.issues
            .any((i) => i.type == 'discriminated_union_error'),
        isTrue,
      );
    });

    test('parseAsync dispatches correctly', () async {
      final result = await shape.parseAsync({'type': 'circle', 'radius': 1.5});
      expect(result['radius'], 1.5);
    });
  });

  // ---------------------------------------------------------------------------
  group('pipe', () {
    test('string -> transform -> int schema', () {
      final schema = z.string().transform(int.parse).pipe(z.int().min(0));
      expect(schema.parse('42'), 42);
    });

    test('propagates next-stage validation errors', () {
      final schema = z.string().transform(int.parse).pipe(z.int().min(10));
      expect(() => schema.parse('5'), throwsA(isA<ZardError>()));
    });

    test('propagates source-stage errors', () {
      final schema = z.string().pipe(z.string().min(3));
      expect(() => schema.parse(123), throwsA(isA<ZardError>()));
    });

    test('works inside a z.map (parseInto path)', () {
      final schema = z.map({
        'n': z.string().transform(int.parse).pipe(z.int().min(0)),
      });
      final ok = schema.parse({'n': '7'});
      expect(ok['n'], 7);

      final bad = schema.safeParse({'n': '-1'});
      expect(bad.success, isFalse);
      expect(bad.error!.issues.any((i) => i.path == 'n'), isTrue);
    });

    test('parseAsync works through the pipe', () async {
      final schema = z.string().transform(int.parse).pipe(z.int().min(0));
      expect(await schema.parseAsync('9'), 9);
    });
  });

  // ---------------------------------------------------------------------------
  group('refineAsync', () {
    test('parseAsync honors a passing async refinement', () async {
      final schema = z.string().refineAsync(
            (v) async => v.length > 2,
            message: 'too short',
          );
      expect(await schema.parseAsync('hello'), 'hello');
    });

    test('parseAsync throws on failing async refinement', () async {
      final schema = z.string().refineAsync(
            (v) async => v.length > 10,
            message: 'too short',
          );
      expect(schema.parseAsync('hi'), throwsA(isA<ZardError>()));
    });

    test('safeParseAsync returns failure with the custom message', () async {
      final schema = z.int().refineAsync(
            (v) async => v.isEven,
            message: 'must be even',
          );
      final res = await schema.safeParseAsync(3);
      expect(res.success, isFalse);
      expect(res.error!.issues.first.message, 'must be even');
      expect(res.error!.issues.first.type, 'refine_error');
    });

    test('safeParseAsync succeeds when predicate passes', () async {
      final schema = z.int().refineAsync((v) async => v.isEven);
      final res = await schema.safeParseAsync(4);
      expect(res.success, isTrue);
      expect(res.data, 4);
    });

    test('sync parse throws StateError telling user to use parseAsync', () {
      final schema = z.string().refineAsync((v) async => true);
      expect(() => schema.parse('x'), throwsA(isA<StateError>()));
    });

    test('supports a synchronous bool predicate too', () async {
      final schema = z.int().refineAsync((v) => v > 0, message: 'positive');
      expect(await schema.parseAsync(5), 5);
      final res = await schema.safeParseAsync(-1);
      expect(res.success, isFalse);
    });

    test('inner validators still run before the async refinement', () async {
      final schema = z.int().min(0).refineAsync(
            (v) async => v < 100,
            message: 'too big',
          );
      // Fails inner min() first.
      final res = await schema.safeParseAsync(-5);
      expect(res.success, isFalse);
    });
  });
}
