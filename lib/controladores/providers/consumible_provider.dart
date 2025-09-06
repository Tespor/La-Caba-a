import 'package:flutter/material.dart';
import 'package:la_cabana/db/database_helper.dart';
import 'package:la_cabana/models/consumible.dart';

class ConsumibleProvider extends ChangeNotifier {
  List<Consumible> _consumibles = [];
  bool _isLoading = false;

  List<Consumible> get consumibles => _consumibles;
  bool get isLoading => _isLoading;

  Future<void> cargarConsumibles() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseHelper.instance;
    _consumibles = await db.obtenerConsumible();

    _isLoading = false;
    notifyListeners();
  }

  Future<int> agregarConsumible(Consumible consumible) async {
    final id = await DatabaseHelper.instance.insertConsumible(consumible);
    final consumibleConId = consumible.copyWith(id: id);
    _consumibles.add(consumibleConId);
    notifyListeners();

    return id;
  }

  Future<List<Map<String, dynamic>>?> eliminarConsumible(int id) async {
    final res = await DatabaseHelper.instance.eliminarConsumible(id);
    
    if(res != null && res.isEmpty) {
      _consumibles.removeWhere((c) => c.id == id);
    }
    notifyListeners();
    

    return res;
  }

  void actualizarCantidad(int id, int nuevaCantidad) async {
    // 1. Actualizar en la base de datos
    await DatabaseHelper.instance.actualizarCantidad(id, nuevaCantidad);

    // 2. Actualizar en la lista local
    final index = _consumibles.indexWhere((c) => c.id == id);
    if (index != -1) {
      _consumibles[index] = _consumibles[index].copyWith(
        cantidad: nuevaCantidad,
      );
      notifyListeners();
    }
  }
}
