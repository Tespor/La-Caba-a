import 'package:la_cabana/models/producto.dart';

class PedidoItem {
  final Producto producto;
  int cantidad;

  PedidoItem({required this.producto, this.cantidad = 1});

  double get total => producto.precio * cantidad;

}
