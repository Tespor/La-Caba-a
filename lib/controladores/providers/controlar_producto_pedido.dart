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


  // Future<bool> agregarProducto(Producto producto) async {
  //   // Obtener consumibles necesarios
  //   final consumibles = await DatabaseHelper.instance.obtenerConsumiblesProducto(producto.id!);

  //   // Validar stock
  //   for (var c in consumibles) {
  //     final requerido = c['requerido'] as int;
  //     final stock = c['stock'] as int;

  //     if (stock < requerido) {
  //       // No hay suficientes consumibles
  //       return false;
  //     }
  //   }

  //   // Si llega aquí, hay consumibles suficientes
  //   final index = _items.indexWhere((item) => item.producto.id == producto.id);
  //   if (index >= 0) {
  //     _items[index].cantidad++;
  //   } else {
  //     _items.add(PedidoItem(producto: producto));
  //   }

  //   notifyListeners();
  //   return true;
  // }


  // void quitarProducto(Producto producto) {
  //   final index = _items.indexWhere((item) => item.producto.id == producto.id);
  //   if (index >= 0) {
  //     if (_items[index].cantidad > 1) {
  //       _items[index].cantidad--;
  //     } else {
  //       _items.removeAt(index);
  //     }
  //     notifyListeners();
  //   }
  // }

  // void limpiarCarrito(){
  //   _items.clear();
  //   notifyListeners();
  // }

  // Agregar producto
  Future<bool> agregarProducto(Producto producto) async {
    final index = _items.indexWhere((i) => i.producto.id == producto.id);

    // Validar stock antes de aumentar cantidad
    final consumibles =
        await DatabaseHelper.instance.obtenerConsumiblesProducto(producto.id!);
    for (var c in consumibles) {
      final stock = c['stock'] as int;
      final requerido = c['requerido'] as int;
      if (stock < requerido) return false; // Stock insuficiente
    }

    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(PedidoItem(producto: producto));
    }

    // Descontar consumibles del stock
    await DatabaseHelper.instance.descontarConsumiblesDeProducto(producto.id!, 1);

    notifyListeners();
    return true;
  }


  // Quitar producto
  Future<void> quitarProducto(Producto producto) async {
    final index = _items.indexWhere((i) => i.producto.id == producto.id);
    if (index != -1) {
      final item = _items[index];

      // Devolver consumibles al stock
      await DatabaseHelper.instance
          .devolverConsumiblesDeProducto(producto.id!, 1);

      if (item.cantidad > 1) {
        item.cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Limpiar carrito
  Future<void> limpiarCarrito() async {
    // Devolver todos los consumibles
    for (var item in _items) {
      await DatabaseHelper.instance
          .devolverConsumiblesDeProducto(item.producto.id!, item.cantidad);
    }
    _items.clear();
    notifyListeners();
  }

  Future<int> cobrarPedido(pagoDelCliente) async {
    if (_items.isEmpty) {
      return -1;
    }

    final total = totalPedido;

    final pedido = Pedido(
      total: total,
      pagoCliente: pagoDelCliente,
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
