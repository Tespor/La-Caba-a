class ProductoConsumible {
  final int idProducto;
  final int idConsumible;
  final int cantidad;

  ProductoConsumible({
    required this.idProducto,
    required this.idConsumible,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_producto': idProducto,
      'id_consumible': idConsumible,
      'cantidad': cantidad,
    };
  }

  factory ProductoConsumible.fromMap(Map<String, dynamic> map) {
    return ProductoConsumible(
      idProducto: map['id_producto'],
      idConsumible: map['id_consumible'],
      cantidad: map['cantidad'],
    );
  }
}