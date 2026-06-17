# AGENTS.md — Guia de contexto para Zard

Este arquivo dá a qualquer agente de IA o contexto completo necessário para **modificar, corrigir ou implementar** funcionalidades no Zard com segurança. Leia-o antes de tocar no código.

## O que é o Zard

Zard é uma biblioteca de **validação e transformação de schemas para Dart**, inspirada no [Zod](https://github.com/colinhacks/zod) do TypeScript. O ponto de entrada é o singleton global `z` (`final z = Zard();`), e a API espelha a do Zod sempre que possível (`z.string()`, `z.int()`, `z.map({...})`, `.parse()`, `.safeParse()`, `.optional()`, `.refine()`, `.transform()`, `z.coerce.*`, etc.).

- **Pacote:** `zard` (pub.dev) — ver `pubspec.yaml` para a versão atual.
- **SDK:** Dart `>=3.0.0 <4.0.0`. Sem dependência de Flutter.
- **Dependência de runtime:** apenas `string_normalizer`.
- **Dev:** `test`, `benchmark_harness`.
- **Lints:** `package:lints/recommended.yaml` (ver `analysis_options.yaml`).

## Layout do projeto

```
lib/
  zard.dart                  # Barrel público — define o que é exportado
  src/
    zard_base.dart           # class Zard + singleton `z`. TODA fábrica (z.string(), z.map(), z.coerce...) vive aqui
    schemas/
      schema.dart            # Schema<T> base abstrata. parse(), parseInto(), safeParse(), optional(), refine(), transform()...
      schemas.dart           # Barrel interno que reexporta todos os schemas
      z_string.dart          # ZString / ZStringImpl / ZCoerceString
      z_int.dart             # ZInt / ZIntImpl / ZCoerceInt
      z_double.dart          # ZDouble / ZDoubleImpl / ZCoerceDouble
      z_num.dart             # ZNum / ZNumImpl / ZCoerceNum
      z_bool.dart            # ZBool / ZBoolImpl / ZCoerceBoolean
      z_date.dart            # ZDate / ZDateImpl / ZCoerceDate
      z_string_bool.dart     # ZStringBool / ZStringBoolImpl / ZCoerceBoolean (variante "boolean-like string")
      z_map.dart             # ZMap — objeto com schema por chave
      z_list.dart            # ZList — lista homogênea
      z_enum.dart            # ZEnum
      z_union.dart           # ZUnion
      z_interface.dart       # ZInterface (variante de objeto)
      z_lazy.dart            # LazySchema (schemas recursivos)
      z_file.dart            # ZFile
      z_optional.dart        # ZOptional<T> (wrapper)
      z_nullable.dart        # ZNullable<T> (wrapper)
      z_default.dart         # ZDefault<T> (wrapper)
      z_coerce_container.dart# ZCoerce — namespace de z.coerce.*
      transformed_schema.dart# TransformedSchema<T,R> — resultado de .transform()/.transformTyped()
    types/
      zard_issue.dart        # ZardIssue — um problema de validação (message, type, value, path)
      zard_error.dart        # ZardError implements Exception — agrega List<ZardIssue>
      zard_result.dart       # ZardResult<T> — retorno de safeParse (success/data/error + unwrap/when)
      parse_context.dart     # ParseContext (lista de issues por parse) + joinPath()
      zard_error_formatter.dart # treeifyError / prettifyError / flattenError
      zard_type.dart         # ZardType<T> — inferência para mapear Map -> classe tipada
    utils/
      regexes.dart           # Regexes pré-compiladas (e-mail, url, uuid, etc.)
      iso.dart               # z.iso.* (date/time/datetime/duration)
test/src/                    # Testes (package:test). Ver convenções abaixo
example/lib/                 # Exemplos executáveis de cada feature
```

## Arquitetura — o que você PRECISA entender

### 1. Todo schema estende `Schema<T>`

`Schema<T>` (`lib/src/schemas/schema.dart`) é a base abstrata. Conceitos-chave:

- **`_validators` / `_transforms`**: listas de funções acumuladas por métodos encadeáveis (`.min()`, `.max()`, `.transform()`...). Validadores retornam `ZardIssue?` (null = ok); transforms mapeiam `T -> T`.
- **`isOptional` / `isNullable`**: olham *através* dos wrappers (`ZOptional`, `ZNullable`, `ZDefault`) recursivamente. Não confie em `is ZOptional` direto — use esses getters.
- **Wrappers** (`optional()`, `nullable()`, `nullish()`, `$default()`): cada um envolve o schema interno numa nova instância (`ZOptional<T>`, etc.). Eles delegam ao `inner`.

### 2. Os DOIS caminhos de parsing — a parte mais importante

Cada schema tem **dois** métodos de parsing, e eles precisam concordar:

| Método | Quem chama | Comportamento em erro |
|---|---|---|
| `T parse(value, {path})` | Código do usuário (caminho público) | **lança** `ZardError` |
| `T? parseInto(value, path, sink)` | Schemas container (`ZMap`, `ZList`, `ZUnion`, `ZInterface`, `TransformedSchema`) | **não lança**; adiciona `ZardIssue`s ao `sink` e retorna `null` |

`parseInto` é o caminho interno rápido — evita o custo de try/catch por campo/item. O sucesso é detectado pelo container comparando `sink.length` antes e depois da chamada.

**A implementação default de `parseInto` (em `Schema`) apenas embrulha `parse()` num try/catch.** Schemas de alta performance (`ZInt`, `ZDouble`, `ZNum`, `ZBool`, `ZString`, `ZList`, `ZMap`) sobrescrevem `parseInto` diretamente para nunca lançar exceção no caminho de falha.

> ⚠️ **ARMADILHA CRÍTICA (causou o bug de coerce em z.map):** se uma subclasse sobrescreve **só `parse()`** mas a classe-pai sobrescreve `parseInto()`, então quando o schema é usado dentro de um container, o `parseInto` da pai é chamado e a lógica do `parse()` da subclasse é **ignorada**.
>
> Foi exatamente o que acontecia com `ZCoerceInt` (etc.): coerce funcionava em `schema.parse()` mas não em `z.map({...})`. A correção foi dar a cada `ZCoerce*` um `parseInto` que delega ao próprio `parse()` coercivo:
> ```dart
> @override
> int? parseInto(dynamic value, String path, List<ZardIssue> sink) {
>   try {
>     return parse(value, path: path);
>   } on ZardError catch (e) {
>     sink.addAll(e.issues);
>     return null;
>   }
> }
> ```
>
> **Regra geral:** ao sobrescrever um dos dois métodos de parsing numa subclasse, verifique se a pai sobrescreve o outro. Se sim, sobrescreva os dois (ou delegue um ao outro). Não deixe os caminhos divergirem.

### 3. Erros: `ZardIssue` → `ZardError` → `ZardResult`

- `ZardIssue`: um problema único. Campos: `message`, `type` (string como `'type_error'`, `'required_error'`, `'min_error'`, `'coerce_error'`, `'refine_error'`, `'strict_error'`...), `value` (valor ofensor), `path` (ex. `'user.address.zip'` ou `'[2]'`).
- `ZardError implements Exception`: agrega `List<ZardIssue>`. Lançado por `parse()`.
- `ZardResult<T>`: retorno de `safeParse()`. `success`, `data`, `error`, mais helpers `unwrap()`, `unwrapOrNull()`, `when(success:, error:)`.
- **Paths**: use `joinPath(base, key)` (de `parse_context.dart`) para construir paths aninhados. Listas usam o formato `'$path[$i]'`.

### 4. Coerção (`z.coerce.*`)

`z.coerce` retorna um `ZCoerce` (`z_coerce_container.dart`) cujos métodos retornam as classes `ZCoerce*` (ex. `ZCoerceInt extends ZInt`). Cada `ZCoerce*`:
1. Sobrescreve `parse()` para converter o input antes de validar (ex. `int.tryParse(value.toString())`).
2. **Deve** sobrescrever `parseInto()` (ver armadilha acima) sempre que a classe-pai o sobrescrever.

`ZCoerceDate` e o `ZCoerceBoolean` de `z_string_bool.dart` funcionam só com o `parse()` sobrescrito porque suas pais (`ZDate`, `ZStringBool`) **não** sobrescrevem `parseInto` — herdam o wrapper default. Confirme isso antes de assumir.

### 5. Como adicionar uma nova feature

Para **um novo tipo de schema** (ex. `z.bigint()`):
1. Crie `lib/src/schemas/z_bigint.dart` com a classe abstrata `ZBigInt extends Schema<BigInt>`, a `ZBigIntImpl`, e (se houver) `ZCoerceBigInt`.
2. Implemente **ambos** `parse()` e `parseInto()` (ou herde o default de um deles conscientemente).
3. Adicione `export 'z_bigint.dart';` em `lib/src/schemas/schemas.dart`.
4. Adicione a fábrica em `lib/src/zard_base.dart`: `ZBigInt bigint({String? message}) => ZBigIntImpl(message: message);` com dartdoc no mesmo estilo dos demais.
5. Se for coercível, adicione `ZCoerceBigInt bigint() => ZCoerceBigInt();` em `z_coerce_container.dart`.
6. Escreva testes em `test/src/schemas/z_bigint_test.dart` e um exemplo em `example/lib/`.

Para **um novo validador** num tipo existente (ex. `.startsWith()` em ZString): adicione um método encadeável que chama `addValidator((v) => ... ? ZardIssue(...) : null)` e retorna `this`. Aceite um `{String? message}` para mensagem custom.

## Convenções de código

- **Nomenclatura:** classe abstrata `ZFoo`, implementação concreta `ZFooImpl`, coerção `ZCoerceFoo`. Fábrica no `Zard` em camelCase (`z.foo()`); para palavras reservadas use `$` (`z.$enum(...)`).
- **Mensagens custom:** todo schema/validador aceita `{String? message}` e usa `message ?? '<default em inglês>'`. Mensagens default são em **inglês**.
- **Métodos encadeáveis** (validadores/transforms) retornam `this` (ou nova instância para wrappers/`partial`/`merge`/`extend`/`pick`/`omit`).
- **Performance importa:** o `parseInto` é caminho quente. Evite alocações desnecessárias (reuso de issue quando `path` é null, listas `growable: false`, `validatorsInternal`/`transformsInternal` em vez dos getters `unmodifiable`). Há benchmarks que comparam o Zard ao Zod/Yup — não regrida performance sem motivo.
- **Comentários** no código existente são majoritariamente em inglês; siga o tom do arquivo que você está editando.
- **Sem dependências novas** sem necessidade clara. O pacote se orgulha de ser leve.

## Fluxo de trabalho ao editar

Sempre, antes de considerar uma mudança pronta:

```bash
dart analyze lib/        # não introduza erros (os 3 infos de unnecessary_import são pré-existentes)
dart test                # roda TODA a suíte; deve passar 100%
```

Para validar uma feature manualmente, edite/rode um exemplo:

```bash
cd example && dart run lib/<arquivo>.dart
```

- A suíte de testes inclui benchmarks (`test/src/zard_benchmark_test.dart`) — eles imprimem ops/sec mas também contam como testes; mantenha-os passando.
- Ao corrigir um bug, **adicione um teste de regressão** no `test/src/schemas/` correspondente que falharia sem a correção. Ex.: o bug de coerce em `z.map` deveria ter um teste `z.coerce.int()` dentro de um `z.map({...})`.

## Convenções de teste

- Framework: `package:test`. Use `group(...)` por schema e `group('Coercion', ...)` para casos de coerce.
- Sucesso: `expect(schema.parse(input), equals(expected))`.
- Falha: `expect(() => schema.parse(input), throwsA(isA<ZardError>()))`.
- Cubra: tipo aceito, tipos rejeitados, `null`, validadores (`min`/`max`/etc.), coerção, e o comportamento **dentro de containers** (`z.map`, `z.list`) quando relevante — é onde os bugs de `parseInto` se escondem.

## Git / releases

- Atualize `CHANGELOG.md` e a `version` em `pubspec.yaml` ao preparar release (segue semver; ver histórico).
- O `README.md` é a documentação pública e extensa (~925 linhas) — atualize-o quando adicionar/alterar API pública.
- Branch principal: `main`. Faça commits só quando solicitado; se estiver na `main`, crie branch antes.

## Checklist rápido antes de finalizar

- [ ] `parse()` e `parseInto()` concordam (sem divergência de caminho)?
- [ ] Funciona isolado **e** dentro de `z.map`/`z.list`?
- [ ] `dart analyze lib/` sem novos erros?
- [ ] `dart test` 100% verde?
- [ ] Teste de regressão/cobertura adicionado?
- [ ] Exportado em `schemas.dart` e fábrica em `zard_base.dart` (se novo tipo)?
- [ ] `README.md` / `CHANGELOG.md` atualizados (se API pública mudou)?
