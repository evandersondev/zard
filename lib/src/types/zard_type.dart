import '../schemas/schema.dart';

abstract class CustomModel {
  // Factory method para criar uma instância a partir de um JSON validado.
  factory CustomModel.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
}

/// ZardType é um Schema customizado que valida um Map e o transforma na instância do modelo T.
class ZardType<T> extends Schema<T> {
  // Função que transforma o Map validado em uma instância do modelo.
  final T Function(Map<String, dynamic> json) fromJson;

  // O schema interno para validar o Map (pode ser um ZMap fora da caixa).
  final Schema<Map<String, dynamic>> mapSchema;

  ZardType({
    required this.fromJson,
    required this.mapSchema,
  });

  @override
  T parse(dynamic value) {
    // Primeiro valida o Map com o schema de Map.
    final validatedMap = mapSchema.parse(value);

    // Aqui você pode ainda customizar validações antes da conversão.
    return fromJson(validatedMap!);
  }
}
