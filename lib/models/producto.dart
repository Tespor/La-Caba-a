class Producto {
  int? id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int categoriaId;
  final String? imagen;

  Producto({this.id, required this.nombre, required this.precio, this.descripcion, required this.categoriaId, this.imagen});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'imagen': imagen,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      precio: (map['precio'] as num).toDouble(),
      descripcion: map['descripcion'],
      categoriaId: map['categoria_id'],
      imagen: map['imagen'],
    );
  }
}
