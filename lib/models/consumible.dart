class Consumible {
  final int? id;
  final String nombre;
  final int cantidad;

  Consumible({this.id, required this.nombre, required this.cantidad});

  Consumible copyWith({
    int? id,
    String? nombre,
    int? cantidad,
  }) {
    return Consumible(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }

  factory Consumible.fromMap(Map<String, dynamic> map) {
    return Consumible(
      id: map['id'],
      nombre: map['nombre'],
      cantidad: map['cantidad'],
    );
  }
}