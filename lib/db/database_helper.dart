import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/categoria.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../models/pedido_detalle.dart';
import '../models/producto_consumible.dart';
import '../models/consumible.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('la_cabana.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);

    print("📁 Ruta base de datos: $path");

    final exists = await File(path).exists();

    if (!exists) {
      // Copiar desde assets
      ByteData data = await rootBundle.load("assets/db/la_cabana.db");
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
    final db = await openDatabase(path);
    await _agregarColumnaReferencia(db);//Verificar si la columna 'referencia' existe y agregarla si no

    return db;
  }

  Future<void> _agregarColumnaReferencia(Database db) async {
    final res = await db.rawQuery("PRAGMA table_info(pedidos);");
    final existe = res.any((columna) => columna['name'] == 'referencia');

    if (!existe) {
      print("🧱 Agregando columna 'referencia' a la tabla pedidos...");
      await db.execute("ALTER TABLE pedidos ADD COLUMN referencia TEXT;");
    }
  }

  //para usar la base de datos desde la carpeta .dart_tool
  // Future<Database> _initDB(String filePath) async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, filePath);

  //   return await openDatabase(
  //     path,
  //     version: 1,
  //     onCreate: _createDB, // Solo corre una vez, cuando la BD no existe
  //   );
  // }

  //Para borrar y copiar siempre la DB desde assets (desarrollo)
  //   Future<Database> _initDB(String filePath) async {
  //   // 📌 Ruta de almacenamiento interno de la app
  //   final dbDir = await getApplicationDocumentsDirectory();
  //   final path = join(dbDir.path, filePath);

  //   // 📌 Verificar si existe la DB y eliminarla
  //   if (await File(path).exists()) {
  //     print("🗑️ Eliminando base de datos vieja en: $path");
  //     await File(path).delete();
  //   }

  //   // 📌 Copiar la DB desde assets
  //   ByteData data = await rootBundle.load("assets/db/la_cabana.db");
  //   List<int> bytes = data.buffer.asUint8List(
  //     data.offsetInBytes,
  //     data.lengthInBytes,
  //   );

  //   await File(path).writeAsBytes(bytes, flush: true);
  //   print("✅ Base de datos copiada desde assets a: $path");

  //   // 📌 Abrir la nueva base de datos
  //   return await openDatabase(path);
  // }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        descripcion TEXT,
        categoria_id INTEGER NOT NULL,
        imagen BLOB,
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE consumibles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        cantidad INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE productos_consumibles (
        id_producto INTEGER NOT NULL,
        id_consumible INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        FOREIGN KEY (id_producto) REFERENCES productos (id) ON DELETE CASCADE,
        FOREIGN KEY (id_consumible) REFERENCES consumibles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        pago_cliente REAL NOT NULL,
        fecha TEXT DEFAULT CURRENT_TIMESTAMP,
        estado TEXT DEFAULT 'pendiente',
        corte BOOLEAN DEFAULT FALSE,
        corte_id INTEGER,
        FOREIGN KEY (corte_id) REFERENCES cortes (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pedido_productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON DELETE CASCADE,
        FOREIGN KEY (producto_id) REFERENCES productos (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cortes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_inicio TEXT,
        fecha_fin TEXT,
        total REAL
      );
    ''');

    await db.execute('''
      INSERT INTO categorias (nombre) VALUES ('Hamburguesas');
      INSERT INTO categorias (nombre) VALUES ('Hot Dog');
      INSERT INTO categorias (nombre) VALUES ('Carne Asada');
      INSERT INTO categorias (nombre) VALUES ('Bebidas');
      INSERT INTO categorias (nombre) VALUES ('Adicionales');
    ''');
  }

  // Métodos para Insertar datos.
  Future<int> insertarCategoria(Categoria categoria) async {
    final db = await instance.database;
    return await db.insert('categorias', categoria.toMap());
  }

  Future<int?> insertarProducto(
    Producto producto, [
    List<Map<String, int>>? consumibles,
  ]) async {
    final db = await instance.database;
    int productoId = 0;

    await db.transaction((txn) async {
      // Insertar el producto
      productoId = await txn.insert('productos', producto.toMap());

      // Insertar los consumibles asociados al producto con cantidad
      if (consumibles != null && consumibles.isNotEmpty) {
        for (var c in consumibles) {
          final idConsumible = c['id'];
          final cantidad = c['cantidad'] ?? 0;
          if (idConsumible != null && cantidad > 0) {
            await txn.insert('productos_consumibles', {
              'id_producto': productoId,
              'id_consumible': idConsumible,
              'cantidad': cantidad,
            });
          }
        }
      }
    });

    return productoId;
  }

  Future<int> insertConsumible(Consumible consumible) async {
    final db = await database;
    return await db.insert('consumibles', consumible.toMap());
  }

  Future<int> insertProductoConsumible(
    ProductoConsumible productoConsumible,
  ) async {
    final db = await database;
    return await db.insert('productos_consumibles', productoConsumible.toMap());
  }

  // Métodos para Obtener datos
  Future<List<Categoria>> obtenerCategorias() async {
    final db = await instance.database;
    final maps = await db.query('categorias');
    return maps.map((e) => Categoria.fromMap(e)).toList();
  }

  Future<List<Producto>> obtenerProductos() async {
    final db = await instance.database;
    final maps = await db.query('productos');
    return maps.map((e) => Producto.fromMap(e)).toList();
  }

  Future<List<Consumible>> obtenerConsumible() async {
    final db = await instance.database;
    final maps = await db.query('consumibles');
    return maps.map((e) => Consumible.fromMap(e)).toList();
  }

  //Devuelve id = 1, nombre = carne, stock = 10, requeridos = 2
  Future<List<Map<String, dynamic>>> obtenerConsumiblesProducto(
    int productoId,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT c.id, c.nombre, c.cantidad as stock, pc.cantidad as requerido
      FROM consumibles c
      INNER JOIN productos_consumibles pc ON c.id = pc.id_consumible
      WHERE pc.id_producto = ?
    ''',
      [productoId],
    );
  }

  Future<List<ProductoConsumible>> obtenerProductosConsumibles() async {
    final db = await instance.database;
    final maps = await db.query('productos_consumibles');
    return maps.map((e) => ProductoConsumible.fromMap(e)).toList();
  }

  Future<List<Producto>> getProductosPorCategoria(int idCategoria) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT productos.* 
      FROM productos 
      JOIN categorias ON productos.categoria_id = categorias.id
      WHERE categorias.id = ?
    ''',
      [idCategoria],
    );

    return result.map((json) => Producto.fromMap(json)).toList();
  }

  //Metodos para Eliminar datos
  Future<int?> eliminarCategoria(int id) async {
    final db = await instance.database;

    // 1. Verificar si hay productos relacionados
    final productos = await db.query(
      'productos',
      where: 'categoria_id = ?',
      whereArgs: [id],
    );

    if (productos.isNotEmpty) {
      // Hay productos relacionados, no se puede eliminar
      return null;
    }

    // 2. Si no hay productos, eliminar la categoría
    final filasEliminadas = await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );

    return filasEliminadas;
  }

  Future<int?> eliminarProducto(int id) async {
    final db = await instance.database;
    int filasEliminadas = 0;

    await db.transaction((txn) async {
      await txn.delete(
        'productos_consumibles',
        where: 'id_producto = ?',
        whereArgs: [id],
      );

      filasEliminadas = await txn.delete(
        'productos',
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    // Si se eliminó 1 fila del producto, retornamos el id; si no, null
    return filasEliminadas > 0 ? id : null;
  }

  Future<List<Map<String, dynamic>>?> eliminarConsumible(int id) async {
    final db = await instance.database;

    // Verificar si el consumible está relacionado con algún producto
    final relaciones = await db.query(
      'productos_consumibles',
      where: 'id_consumible = ?',
      whereArgs: [id],
    );

    if (relaciones.isNotEmpty) {
      // Obtener los productos relacionados
      final productosRelacionados = await db.rawQuery(
        '''
        SELECT p.id, p.nombre 
        FROM productos p
        INNER JOIN productos_consumibles pc ON p.id = pc.id_producto
        WHERE pc.id_consumible = ?
      ''',
        [id],
      );

      // Devuelves la lista de productos relacionados en lugar de eliminar
      return productosRelacionados;
    }

    // Si no tiene relaciones, eliminamos directo dentro de la transacción
    int filasEliminadas = 0;
    await db.transaction((txn) async {
      filasEliminadas = await txn.delete(
        'consumibles',
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    // Si se eliminó correctamente, devolvemos una lista vacía para indicar "sin relaciones"
    return filasEliminadas > 0 ? [] : null;
  }

  //Actualizar
  Future<int> actualizarCantidad(int id, int nuevaCantidad) async {
    final db = await instance.database;
    return await db.update(
      'consumibles',
      {'cantidad': nuevaCantidad},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> actualizarProducto(
    Producto producto,
    List<Map<String, int>> consumibles,
  ) async {
    final db = await instance.database;
    int filas = 0;

    await db.transaction((txn) async {
      // Actualizamos el producto
      filas = await txn.update(
        'productos',
        producto.toMap(),
        where: 'id = ?',
        whereArgs: [producto.id],
      );

      // Eliminamos consumibles anteriores
      await txn.delete(
        'productos_consumibles',
        where: 'id_producto = ?',
        whereArgs: [producto.id],
      );

      // Insertamos los consumibles nuevos
      for (var c in consumibles) {
        final idConsumible = c['id'];
        final cantidad = c['cantidad'] ?? 0;
        if (idConsumible != null && cantidad > 0) {
          await txn.insert('productos_consumibles', {
            'id_producto': producto.id,
            'id_consumible': idConsumible,
            'cantidad': cantidad,
          });
        }
      }
    });

    return filas;
  }

  //Pedidos
  Future<int> insertarPedido( Pedido pedido, List<PedidoProducto> productos,) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      // 1️⃣ Insertar pedido
      final pedidoId = await txn.insert('pedidos', pedido.toMap());

      // 2️⃣ Insertar productos del pedido y actualizar consumibles
      for (var p in productos) {
        // Insertar producto en pedido_productos
        await txn.insert('pedido_productos', {
          'pedido_id': pedidoId,
          'producto_id': p.productoId,
          'cantidad': p.cantidad,
          'precio_unitario': p.precioUnitario,
        });

        // Obtener consumibles asociados al producto
        final consumiblesProducto = await txn.query(
          'productos_consumibles',
          where: 'id_producto = ?',
          whereArgs: [p.productoId],
        );

        // Restar la cantidad usada de cada consumible
        for (var c in consumiblesProducto) {
          final idConsumible = c['id_consumible'] as int;
          final cantidadRequerida = (c['cantidad'] as int) * p.cantidad;

          // Actualizar stock del consumible
          await txn.rawUpdate(
            'UPDATE consumibles SET cantidad = cantidad - ? WHERE id = ?',
            [cantidadRequerida, idConsumible],
          );
        }
      }

      return pedidoId;
    });
  }

  Future<List<Pedido>> obtenerPedidosActivos() async {
    final db = await instance.database;
    final result = await db.query(
      'pedidos',
      where: 'corte = ?',
      whereArgs: [0],
      orderBy: 'fecha DESC',
    );
    return result.map((json) => Pedido.fromMap(json)).toList();
  }

  Future<List<Pedido>> obtenerPedidosTodos() async {
    final db = await instance.database;
    final result = await db.query('pedidos', orderBy: 'fecha DESC');
    return result.map((json) => Pedido.fromMap(json)).toList();
  }

  // Obtener todos los cortes
  Future<List<Map<String, dynamic>>> obtenerCortes() async {
    final db = await instance.database;
    return await db.query('cortes', orderBy: 'id DESC');
  }

  // Obtener pedidos de un corte
  Future<List<Pedido>> obtenerPedidosPorCorte(int corteId) async {
    final db = await instance.database;
    final result = await db.query(
      'pedidos',
      where: 'corte_id = ?',
      whereArgs: [corteId],
      orderBy: 'fecha ASC',
    );
    return result.map((e) => Pedido.fromMap(e)).toList();
  }

  Future<int> obtenerTotalPedidosPorCorte(int corteId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT total
      FROM cortes
      WHERE corte_id = ?
    ''',
      [corteId],
    );

    return result.isNotEmpty ? (result.first['total'] as num).toInt() : 0;
  }

  Future<List<Map<String, dynamic>>> obtenerLineasPedido(int pedidoId) async {
    final db = await instance.database;
    // Incluimos nombre del producto para mostrar en el historial
    final result = await db.rawQuery(
      '''
      SELECT 
          pp.id, 
          pp.pedido_id, 
          pp.producto_id, 
          p.nombre AS producto_nombre,
          pp.cantidad, 
          pp.precio_unitario,
          pe.corte
      FROM pedido_productos pp
      JOIN productos p ON p.id = pp.producto_id
      JOIN pedidos pe ON pe.id = pp.pedido_id
      WHERE pp.pedido_id = ?;
    ''',
      [pedidoId],
    );
    return result;
  }

  Future<double> obtenerTotalVentasActual() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT SUM(total) as total
      FROM pedidos
      WHERE estado = 'pagado' AND corte_id IS NULL
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }


  Future<int> cancelarPedido(int id) async {
    final db = await instance.database;
    return await db.update(
      'pedidos',
      {'estado': 'cancelado'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Future<int> eliminarPedidosCancelados() async {
  //   final db = await instance.database;

  //   // Primero elimina las líneas de pedido (pedido_productos) relacionadas con pedidos cancelados
  //   await db.delete(
  //     'pedido_productos',
  //     where: 'pedido_id IN (SELECT id FROM pedidos WHERE estado = ?)',
  //     whereArgs: ['cancelado'],
  //   );

  //   // Luego elimina los pedidos cancelados
  //   final count = await db.delete(
  //     'pedidos',
  //     where: 'estado = ?',
  //     whereArgs: ['cancelado'],
  //   );

  //   return count; // cantidad de pedidos eliminados
  // }

  Future<int?> cerrarCorte() async {
    final db = await instance.database;

    // 1. Traemos todos los pedidos que están pagados y aún no tienen corte
    final pedidos = await db.query(
      'pedidos',
      where: 'corte = ?',
      whereArgs: [0],
    );

    final pedidosActivos = await db.query(
      'pedidos',
      where: 'corte = ? AND estado = ?',
      whereArgs: [0, 'pagado'],
    );

    if (pedidos.isEmpty) {
      return null; // No hacer nada si no hay pedidos
    }

    // 2. Calcular fechas y total
    final fechaInicio = pedidos.first['fecha'] as String;
    final fechaFin = pedidos.last['fecha'] as String;
    final total = pedidosActivos.fold<double>(
      0.0,
      (suma, row) => suma + (row['total'] as num).toDouble(),
    );

    // 3. Insertar en tabla cortes
    final idCorte = await db.insert('cortes', {
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'total': total,
    });

    // 4. Actualizar pedidos para marcar el corte y asignar corte_id
    for (var p in pedidos) {
      await db.update(
        'pedidos',
        {
          'corte': 1, // marcar como cerrado
          'corte_id': idCorte, // asignar el id del corte
        },
        where: 'id = ?',
        whereArgs: [p['id']],
      );
    }

    return idCorte;
  }

  // Future<List<Map<String, dynamic>>> obtenerVentasTotalesProductos() async {
  //   final db = await instance.database;

  //   final result = await db.rawQuery('''
  //     SELECT 
  //         pr.id AS producto_id,
  //         pr.nombre AS nombre_producto,
  //         SUM(pp.cantidad) AS total
  //     FROM cortes c
  //     JOIN pedidos pe ON pe.corte_id = c.id
  //     JOIN pedido_productos pp ON pp.pedido_id = pe.id
  //     JOIN productos pr ON pr.id = pp.producto_id
  //     WHERE c.id = (SELECT MAX(id) FROM cortes)
  //       AND pe.estado = 'pagado'
  //     GROUP BY pr.id, pr.nombre
  //     ORDER BY total DESC;
  //   ''');

  //   return result;
  // }

  Future<List<Map<String, dynamic>>> obtenerVentasTotalesProductos() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT 
          pr.id AS producto_id,
          pr.nombre AS nombre_producto,
          SUM(pp.cantidad) AS total,
          SUM(pp.cantidad * pp.precio_unitario) AS total_dinero
      FROM cortes c
      JOIN pedidos pe ON pe.corte_id = c.id
      JOIN pedido_productos pp ON pp.pedido_id = pe.id
      JOIN productos pr ON pr.id = pp.producto_id
      WHERE c.id = (SELECT MAX(id) FROM cortes)
        AND pe.estado = 'pagado'
      GROUP BY pr.id, pr.nombre
      ORDER BY total_dinero DESC;
    ''');
    return result;
  }


  // Eliminar pedidos con más de 30 días de antigüedad
  Future<int> eliminarPedidosAntiguos() async {
    final db = await instance.database;

    // Fecha límite (ahora - 30 días)
    final limite = DateTime.now().subtract(Duration(days: 30));
    final limiteStr = limite.toIso8601String();

    return await db.transaction((txn) async {
      // 1. Obtener los IDs de los pedidos antiguos
      final pedidosAntiguos = await txn.query(
        'pedidos',
        where: 'fecha < ?',
        whereArgs: [limiteStr],
        columns: ['id'],
      );

      if (pedidosAntiguos.isEmpty) return 0;

      final ids = pedidosAntiguos.map((p) => p['id'] as int).toList();

      // 2. Generar placeholders dinámicos (?,?,?,...)
      final placeholders = List.filled(ids.length, '?').join(',');

      // 3. Borrar primero de pedido_productos
      await txn.delete(
        'pedido_productos',
        where: 'pedido_id IN ($placeholders)',
        whereArgs: ids,
      );

      // 4. Borrar pedidos
      final count = await txn.delete(
        'pedidos',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      return count;
    });
  }

  // 🔽 Descontar stock al agregar producto al carrito/pedido
  Future<void> descontarConsumiblesDeProducto(int productoId, int cantidad) async {
    final db = await instance.database;

    // obtener los consumibles requeridos
    final consumibles = await db.query(
      'productos_consumibles',
      where: 'id_producto = ?',
      whereArgs: [productoId],
    );

    for (var c in consumibles) {
      final idConsumible = c['id_consumible'] as int;
      final requerido = (c['cantidad'] as int) * cantidad;

      await db.rawUpdate(
        'UPDATE consumibles SET cantidad = cantidad - ? WHERE id = ?',
        [requerido, idConsumible],
      );
    }
  }

  // 🔽 Devolver stock al eliminar producto del carrito/pedido
  Future<void> devolverConsumiblesDeProducto(int productoId, int cantidad) async {
    final db = await instance.database;

    // obtener los consumibles requeridos
    final consumibles = await db.query(
      'productos_consumibles',
      where: 'id_producto = ?',
      whereArgs: [productoId],
    );

    for (var c in consumibles) {
      final idConsumible = c['id_consumible'] as int;
      final requerido = (c['cantidad'] as int) * cantidad;

      await db.rawUpdate(
        'UPDATE consumibles SET cantidad = cantidad + ? WHERE id = ?',
        [requerido, idConsumible],
      );
    }
  }
}
