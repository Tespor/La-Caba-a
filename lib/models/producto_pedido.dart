import 'package:la_cabana/controladores/variables/global_variables.dart';
import 'package:la_cabana/models/producto.dart';

class PedidoItem {
  final Producto producto;
  int cantidad;

  PedidoItem({required this.producto, this.cantidad = 1});

  double get total => producto.precio * cantidad;

    // 👇 Factory para construir desde Map
  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    return PedidoItem(
      producto: Producto(
        id: map['producto_id'] as int?,
        nombre: map['producto_nombre'] as String,
        precio: (map['precio_unitario'] as num).toDouble(),
        categoriaId: globalCategoriaSeleccionadaId,
        descripcion: '',
      ),
      cantidad: map['cantidad'] as int,
    );
  }

  // (opcional) Para guardar en BD si lo necesitas
  Map<String, dynamic> toMap() {
    return {
      'producto_id': producto.id,
      'nombre': producto.nombre,
      'precio': producto.precio,
      'cantidad': cantidad,
    };
  }

}
