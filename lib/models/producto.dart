import 'dart:typed_data';

class Producto {
  int? id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int categoriaId;
  final Uint8List? imagen;

  Producto({this.id, required this.nombre, required this.precio, this.descripcion, required this.categoriaId, this.imagen});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'imagen': imagen, // Uint8List se guarda como BLOB
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      precio: map['precio'] as double,
      descripcion: map['descripcion'] as String?,
      categoriaId: map['categoria_id'] as int,
      imagen: map['imagen'] != null ? map['imagen'] as Uint8List : null,
    );
  }
}
