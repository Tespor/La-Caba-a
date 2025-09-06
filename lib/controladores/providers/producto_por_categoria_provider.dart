import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../db/database_helper.dart';

class ProductoxCategoriaProvider extends ChangeNotifier {
  List<Producto> _productos = [];

  List<Producto> get productos => _productos;

  void setProductos(List<Producto> productos) {
    _productos = productos;
    notifyListeners();
  }

  void agregarProducto(Producto producto) {
    _productos.add(producto);
    notifyListeners();
  }

  // Future<void> eliminarProducto(int id) async {
  //   final eliminado = await DatabaseHelper.instance.eliminarProducto(id);

  //   if (eliminado != null) {
  //     _productos.removeWhere((p) => p.id == id);
  //     notifyListeners();
  //   }
  // }

  // Eliminar producto
  Future<void> eliminarProducto(int id) async {
    final eliminado = await DatabaseHelper.instance.eliminarProducto(id);

    if (eliminado != null) {
      _productos.removeWhere((p) => p.id == id);
      notifyListeners();
    }
  }

  Future<Producto?> actualizarProducto(Producto producto, List<Map<String, int>> consumibles) async {
    final db = DatabaseHelper.instance;

    // Primero actualizamos el producto
    final filas = await db.actualizarProducto(producto, consumibles);

    if (filas > 0) {
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index != -1) {
        _productos[index] = producto;
        notifyListeners();
      }
      return producto; 
    }
    return null;
  }

}
