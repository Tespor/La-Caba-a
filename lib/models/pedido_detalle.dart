//import 'producto.dart';

class PedidoProducto {
  final int? id;
  final int? pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;

  PedidoProducto({
    this.id,
    this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }
}
