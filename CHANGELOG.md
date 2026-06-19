## 1.2.0

Introspectable constraints — no breaking changes.

### Added
- Constraint metadata is now recorded as introspectable data alongside each
  validator, so a schema can be exported to JSON Schema / OpenAPI **without
  executing it** (mirrors Zod's `_def`). New public API on `Schema`:
  - `addCheck(check, [value])` — records a `{'check': <JSON Schema keyword>,
    'value': v}` entry (called internally by the builder methods).
  - `checks` getter — an unmodifiable view of those entries.
- Builder methods now populate this metadata:
  - `ZString`: `min`/`max`/`length` (→ `minLength`/`maxLength`), `regex`
    (→ `pattern`), and `format` for `email`, `url` (→ `uri`), `uuid`, `date`,
    `time`, `datetime` (→ `date-time`), `ipv4`, `ipv6`, `hostname` and the ISO
    variants.
  - `ZInt`/`ZDouble`/`ZNum`: `min`/`max` (→ `minimum`/`maximum`), `positive`
    (→ `exclusiveMinimum: 0`), `nonnegative` (→ `minimum: 0`), `negative`
    (→ `exclusiveMaximum: 0`), `multipleOf`.
  - `ZList`: `min`/`max`/`noempty`/`lenght` (→ `minItems`/`maxItems`).

### Notes
- Fully additive: validation behavior and all method signatures are unchanged.
- Closure-only constraints (`refine`/`transform`) carry no metadata by design —
  they still validate at runtime but cannot be represented in an exported schema.

## 1.1.3

Bug fix — no breaking changes.

### Fixed
- Coercion schemas (`z.coerce.int()`, `z.coerce.double()`, `z.coerce.num()`,
  `z.coerce.bool()`, `z.coerce.string()`) now coerce correctly when nested inside
  container schemas such as `z.map({...})` and `z.list(...)`. Previously the
  container's internal `parseInto` path dispatched to the non-coercing base type,
  so coercion was silently skipped (e.g. `z.map({'n': z.coerce.int()}).parse({'n': '7'})`
  threw a type error instead of returning `{'n': 7}`).

## 1.1.2

Additive introspection — no breaking changes.

- Export the wrapper schema types `ZOptional`, `ZNullable` and `ZUnion` so their
  `inner` / `schemas` can be introspected (e.g. for OpenAPI / JSON Schema
  generation). `ZDefault` was already exported.

## 1.1.1

Introspection getters and small fixes — no breaking changes.

### Added
- `ZList.element` — the item schema of a list.
- `ZEnum.values` — the allowed values of an enum.

These enable schema introspection (e.g. generating OpenAPI / JSON Schema from
zard schemas). Object shape (`ZMap.schemas`), `ZOptional.inner`,
`ZNullable.inner`, `ZDefault.inner`/`defaultValue` and `ZUnion.schemas` were
already public.

### Fixed
- `isNullable` / `isOptional` now look *through* wrapper schemas, so a schema
  that is both nullable and optional reports `true` for both — whether built
  with `nullish()` (`ZNullable(ZOptional(x))`) or `nullable().optional()`
  (`ZOptional(ZNullable(x))`).
- Removed an unreachable, always-throwing `null as String` cast in
  `ZString.parse` (a bare `ZString` is never nullable; nullability is handled by
  the `ZNullable` wrapper).

## 1.1.0

Major performance refactor — zero breaking changes, all existing tests pass.

### Performance
- Precompiled all built-in `RegExp` patterns (email, uuid, cuid, ipv4/6, iso*, hex, base64, jwt, nanoid, ulid, mac, cidr, etc.) as `static final` — previously recompiled on every `parse()` call.
- New no-throw internal `parseInto` path: container schemas (`ZMap`, `ZList`, `ZUnion`, `ZInterface`, `TransformedSchema`) and primitives (`ZInt`, `ZDouble`, `ZNum`, `ZBool`, `ZString`, `ZEnum`) write errors directly into a caller-provided sink instead of throwing per field/item. Eliminates the dominant try/catch cost in nested validation.
- Reused `ParseContext` across calls via in-place `issues.clear()` (no allocation per `parse()`).
- Replaced `List.unmodifiable` wrappers in hot paths with direct `validatorsInternal` / `transformsInternal` getters.
- Removed redundant `ZardIssue` re-wrap when `path` is empty.
- `ZMap.parse` uses `for-in` over `entries` (no closure allocation per field) and a single `value[key]` lookup instead of `containsKey` + index.
- `ZUnion.parse` skips the inner `safeParse` indirection.
- `ZDefault.parse` uses `rethrow` (one allocation instead of three).

### Benchmarks
- Added `benchmark_harness` as dev dependency.
- New canonical benchmark suite at [`test/src/benchmarks/zard_harness_benchmark.dart`](test/src/benchmarks/zard_harness_benchmark.dart).
- Expanded Stopwatch-based suite at [`test/src/benchmarks/zard_benchmark.dart`](test/src/benchmarks/zard_benchmark.dart) (5k warmup + 100k iterations, parity with Zod).
- Expanded `yup_benchmark.js` to match Zod's full scenario list (Transform, Default, Nullable, Union, safeParse).
- New `run-all.sh` orchestrator runs Dart (JIT + AOT) + Node (Zod + Yup) in one shot.

### Results (µs/op, Dart 3.11 JIT vs Node 24 V8)
| Scenario | Zard 1.0.0 | Zard 1.1.0 | Zod | Yup |
|---|---|---|---|---|
| String valid | 0.36 | **0.05** | 0.11 | 1.27 |
| String invalid | — | **0.55** | 19.67 | 29.28 |
| Small object | 1.11 | **0.36** | 0.37 | 3.82 |
| Complex nested | 6.69 | **2.93** | 0.89 | 40.62 |
| Transform | — | **0.06** | 0.24 | 0.81 |
| Default | 0.04 | **0.01** | 0.06 | 0.74 |
| Union (int) | 0.83 | **0.08** | 0.16 | 1.19 |

Zard now beats Zod on **8 of 11 scenarios** and is **6–60× faster than Yup** across the board.

### Notes
- All public API preserved: `getValidators()`, `getTransforms()`, `getErrors()`, `addError()`, `clearErrors()`, the `issues` getter, etc.
- New (additive) API: `Schema.parseInto(value, path, sink)` — internal use, callable but intended for container schemas.

## 1.0.0

- Add more validation rules, refine, parseAsync, safeParseAsync, coerce, strict.

## 0.0.26

- Fix optional schema from ZMap.

## 0.0.25

- Chore ZString and ZMap, add Iso, Regexes and ZStringBool.

## 0.0.24

- Add ZDefault to define a default value.

## 0.0.23

- Chore interfaces schemas to improve usability.

## 0.0.22

- Improve to add type result from safeParse.

## 0.0.21

- Update transform method.

## 0.0.20

- Fix path error from ZInt.

## 0.0.19

- Fix inferType refine validation and improve type safety.

## 0.0.18

- Chore nullable return from ZMap parse async, add file method and fix $enum type.

## 0.0.17

- Chore nullable return from ZMap parse.

## 0.0.16

- Add path key to ZardIssue.

## 0.0.15

- Add generic type to ZardResult.

## 0.0.14

- Export ZardResult type.

## 0.0.13

- Add z.interface, z.lazy, z.interType and transformTyped.

## 0.0.12

- Add ZardResult type and update custom message.

## 0.0.11

- Update ZMap Validation.

## 0.0.10

- Update ZardError type to Exception.

## 0.0.9

- Update validation .optional and .nullable.

## 0.0.7

- Export ZardError type.

## 0.0.6

- Export schema types.

## 0.0.5

- Add more validation rules, refine, parseAsync, safeParseAsync, coerce, strict.

## 0.0.5

- Update .parse validation rules.

## 0.0.4

- ZMap updated.

## 0.0.3

- Update README.md

## 0.0.2

- Add more validation rules.

## 0.0.1

- Initial version of the package.
