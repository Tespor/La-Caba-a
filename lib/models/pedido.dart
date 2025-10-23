class Pedido {
  final int? id;
  final double total;
  final double pagoCliente;
  final String fecha;
  final String estado; // pendiente, pagado, cancelado

  Pedido({
    this.id,
    required this.total,
    required this.pagoCliente,
    required this.fecha,
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'pago_cliente': pagoCliente,
      'fecha': fecha,
      'estado': estado,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      total: map['total'],
      pagoCliente: map['pago_cliente'],
      fecha: map['fecha'],
      estado: map['estado'],
    );
  }
}
