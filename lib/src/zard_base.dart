import 'schemas/schemas.dart';

typedef Validator<T> = String? Function(T value);

class Zard {
  ZString string() => ZString();
  ZInt int() => ZInt();
  ZDouble double() => ZDouble();
  ZMap map(Map<String, Schema> schema) => ZMap(schema);
  ZList list(Schema itemSchema) => ZList(itemSchema);
  ZBool bool() => ZBool();
  ZDate date() => ZDate();
  ZEnum enumerate(List<String> values) => ZEnum(values);
}

final z = Zard();
