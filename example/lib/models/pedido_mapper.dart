import 'package:example/models/pedidos.dart';
import 'package:zard/zard.dart';

final pedidoProdutoSchema = z.inferType(
    fromMap: (json) {
      return PedidoProduto(
        id: json['id'] as String,
        nome: json['nome'] as String,
        preco: json['preco'] as double,
        quantidade: json['quantidade'] as int,
      );
    },
    mapSchema: z.map({
      'id': z.string(),
      'nome': z.string().min(3),
      'preco': z.double().positive(),
      'quantidade': z.int().positive(),
    }));

final pedidoSchema = z.inferType(
    fromMap: (json) {
      return Pedido(
        id: json['numero_pedido'] as String,
        status: PedidoStatus.values.firstWhere(
          (status) => status.name == json['status'],
        ),
        produto: json['produto'] as PedidoProduto,
      );
    },
    mapSchema: z.map({
      'numero_pedido': z.string(),
      'status': z.$enum(['cancelado', 'processando', 'enviado', 'entregue']),
      'produto': pedidoProdutoSchema.mapSchema,
    }));
