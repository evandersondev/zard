enum PedidoStatus { cancelado, processando, enviado, entrege }

class Pedido {
  final String id;
  final PedidoStatus status;
  final PedidoProduto produto;

  Pedido({
    required this.id,
    required this.status,
    required this.produto,
  });

  @override
  String toString() => 'Pedido(id: $id, status: $status, produto: $produto)';
}

class PedidoProduto {
  final String id;
  final String nome;
  final double preco;
  final int quantidade;

  PedidoProduto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  @override
  String toString() {
    return 'PedidoProduto(id: $id, nome: $nome, preco: $preco, quantidade: $quantidade)';
  }
}
