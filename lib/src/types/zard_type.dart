import '../schemas/schema.dart';
import '../types/zard_error.dart';
import '../types/zard_issue.dart';

abstract class CustomModel {
  // Factory method para criar uma instância a partir de um JSON validado.
  factory CustomModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}

/// ZardType é um Schema customizado que valida um Map e o transforma na instância do modelo T.
class ZardType<T> extends Schema<T> {
  // Função que transforma o Map validado em uma instância do modelo.
  final T Function(Map<String, dynamic> json) fromMap;

  // O schema interno para validar o Map (pode ser um ZMap fora da caixa).
  final Schema<Map<String, dynamic>> mapSchema;

  ZardType({
    required this.fromMap,
    required this.mapSchema,
  });

  @override
  T parse(dynamic value, {String? path}) {
    // Primeiro valida o Map com o schema de Map.
    final validatedMap = mapSchema.parse(value);

    // Converte o Map validado para a instância do modelo
    final result = fromMap(validatedMap);

    // Executa os validadores herdados do Schema base (incluindo refine)
    for (final validator in getValidators()) {
      final error = validator(result);
      if (error != null) {
        addError(error);
      }
    }

    // Executa as transformações
    T transformedResult = result;
    for (final transform in getTransforms()) {
      transformedResult = transform(transformedResult);
    }

    // Se houver erros, lança exceção
    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    return transformedResult;
  }
}
