class Pedido {
  final int? id;
  final double total;
  final String fecha;
  final String estado; // pendiente, pagado, cancelado

  Pedido({
    this.id,
    required this.total,
    required this.fecha,
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'fecha': fecha,
      'estado': estado,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      total: map['total'],
      fecha: map['fecha'],
      estado: map['estado'],
    );
  }
}
