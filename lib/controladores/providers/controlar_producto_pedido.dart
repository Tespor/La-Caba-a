import 'package:flutter/material.dart';
import 'package:la_cabana/models/producto.dart';
import 'package:la_cabana/models/pedido.dart';
import 'package:la_cabana/models/pedido_detalle.dart';
import 'package:la_cabana/models/producto_pedido.dart';
import 'package:la_cabana/db/database_helper.dart';

class PedidoProvider with ChangeNotifier {
  final List<PedidoItem> _items = [];
  int? _ultimoPedidoId;

  List<PedidoItem> get items => _items;
  int? get ultimoPedidoId => _ultimoPedidoId;


  Future<bool> agregarProducto(Producto producto) async {
    // Obtener consumibles necesarios
    final consumibles = await DatabaseHelper.instance.obtenerConsumiblesProducto(producto.id!);

    // Validar stock
    for (var c in consumibles) {
      final requerido = c['requerido'] as int;
      final stock = c['stock'] as int;

      if (stock < requerido) {
        // No hay suficientes consumibles
        return false;
      }
    }

    // Si llega aquí, hay consumibles suficientes
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(PedidoItem(producto: producto));
    }

    notifyListeners();
    return true;
  }


  void quitarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void limpiarCarrito(){
    _items.clear();
    notifyListeners();
  }

  Future<int> cobrarPedido() async {
    if (_items.isEmpty) {
      throw Exception('No hay productos en el pedido');
    }

    final total = totalPedido;

    final pedido = Pedido(
      total: total,
      fecha: DateTime.now().toIso8601String(),
      estado: 'pagado',
    );

    final lineas = _items.map((i) {
      return PedidoProducto(
        productoId: i.producto.id!,
        cantidad: i.cantidad,
        precioUnitario: i.producto.precio,
      );
    }).toList();

    final pedidoId = await DatabaseHelper.instance.insertarPedido(pedido, lineas);
    _ultimoPedidoId = pedidoId;
    notifyListeners();

    return pedidoId;
  }

  double get totalPedido =>
      _items.fold(0, (sum, item) => sum + item.total);
}
