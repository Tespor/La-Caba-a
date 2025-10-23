import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_cabana/db/database_helper.dart';
import 'package:la_cabana/models/pedido.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:la_cabana/models/producto_pedido.dart';
import 'package:la_cabana/widgets/ticket_printer.dart';
import 'package:la_cabana/widgets/ticket_corte.dart';
import 'package:la_cabana/widgets/grafica.dart';

class HistorialPedidos extends StatefulWidget {
  final GlobalKey<GraficaState> graficaKey;

  const HistorialPedidos({super.key, required this.graficaKey});

  @override
  State<HistorialPedidos> createState() => _HistorialPedidosState();
}

class _HistorialPedidosState extends State<HistorialPedidos> {
  late Future<List<Pedido>> _future;
  List<Map<String, dynamic>> cortes = [];
  int? corteSeleccionado; // ID del corte seleccionado
  double? corteTotalSeleccionado;
  String corteFechaSeleccionado = '';
  double totalVentasActual = 0.0;

  @override
  void initState() {
    super.initState();
    _reload();
    _loadCortes();
    _loadTotalVentasActual();
  }

  void _reload() {
    _future = DatabaseHelper.instance.obtenerPedidosActivos();
    setState(() {});
  }

  Future<void> _loadTotalVentasActual() async {
    final total = await DatabaseHelper.instance.obtenerTotalVentasActual();
    setState(() {
      totalVentasActual = total;
    });
  }

  Future<void> _loadCortes() async {
    final data = await DatabaseHelper.instance.obtenerCortes();
    setState(() {
      cortes = data;
    });
  }

  Future<void> _verCorte(int corteId) async {
    setState(() {
      _future = DatabaseHelper.instance.obtenerPedidosPorCorte(corteId);
      corteSeleccionado = corteId;
    });
  }

  Future<void> _cancelar(int id) async {
    await DatabaseHelper.instance.cancelarPedido(id);
    if (corteSeleccionado != null) {
      _verCorte(corteSeleccionado!);
    } else {
      _reload();
    }
    _loadTotalVentasActual();
  }

  Future<List<Map<String, dynamic>>> _lineas(int pedidoId) {
    return DatabaseHelper.instance.obtenerLineasPedido(pedidoId);
  }

  // Funciones auxiliares para obtener colores e iconos según el estado
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Colors.green.shade600;
      case 'cancelado':
        return Colors.red.shade600;
      case 'pendiente':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Icons.check_circle_rounded;
      case 'cancelado':
        return Icons.cancel_rounded;
      case 'pendiente':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.amber),
                const SizedBox(width: 10),
                const Text(
                  'Historial de pedidos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (cortes.isNotEmpty)
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<int>(
                        isExpanded: true,
                        value: corteSeleccionado,
                        hint: const Text(
                          "CORTES",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        items: cortes.map((c) {
                          final ahora = DateTime.parse(c['fecha_inicio']);
                          final fecha = DateFormat('dd/MM/yyyy').format(ahora);
                    
                          return DropdownMenuItem<int>(
                            value: c['id'],
                            child: Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(fecha,
                                    style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold
                                    )
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (context) {
                          return cortes.map((c) {
                            final ahora = DateTime.parse(c['fecha_inicio']);
                            final fecha = DateFormat('dd/MM/yyyy').format(ahora);
                            return Row(
                              children: [
                                const Icon(Icons.date_range, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  fecha,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis, // evita saltos de línea
                                ),
                              ],
                            );
                          }).toList();
                        },
                        onChanged: (id) {
                          if (id != null) _verCorte(id);
                          corteFechaSeleccionado =
                              cortes.firstWhere((c) => c['id'] == id)['fecha_inicio'];
                          corteTotalSeleccionado =
                              cortes.firstWhere((c) => c['id'] == id)['total'] as double;
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 153, 0),
                                Color.fromARGB(255, 255, 204, 0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        iconStyleData: const IconStyleData(
                          iconEnabledColor: Colors.white,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 300, // límite de alto
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 153, 0),
                                Color.fromARGB(255, 255, 204, 0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.amber),
                  onPressed: () {
                    corteSeleccionado = null; // volver a historial normal
                    _reload();
                  },
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: FutureBuilder<List<Pedido>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay pedidos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final pedidos = snap.data!;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (_, i) {
                      final p = pedidos[i];
                      final ahora = DateTime.parse(p.fecha);
                      final fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(ahora);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          clipBehavior: Clip.none,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.only(bottom: 12),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Pedido #${p.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pago del cliente
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.request_page_rounded, 
                                          color: Colors.green.shade500, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Pago del cliente: \$${p.pagoCliente.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green.shade500,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Total del pedido
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_money_sharp, 
                                          color: Colors.green.shade700, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Total: \$${p.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Estado y Fecha en una fila
                                  Row(
                                    children: [
                                      // Estado
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getEstadoColor(p.estado).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: _getEstadoColor(p.estado).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getEstadoIcon(p.estado),
                                                color: _getEstadoColor(p.estado),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  p.estado.toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: _getEstadoColor(p.estado),
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Fecha
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              color: Colors.grey.shade600,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                fechaHora,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final rows = await _lineas( p.id!,);
                                      final items = rows.map((row) => PedidoItem.fromMap(row)).toList();
                                      imprimirTicket(
                                        pedidoId: p.id!,
                                        items: items, 
                                        total: p.total,
                                        pagoCliente: p.pagoCliente,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.print_rounded,
                                      color: Colors.blue.shade600,
                                      size: 22,
                                    ),
                                  ),

                                  if (corteSeleccionado == null && p.estado != 'cancelado')
                                    IconButton(
                                      icon: Icon(Icons.cancel_rounded, 
                                                color: Colors.red.shade600, size: 22),
                                      tooltip: "Cancelar pedido",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(Icons.warning_amber_rounded, 
                                                    color: Colors.orange.shade600),
                                                const SizedBox(width: 8),
                                                const Text("Confirmar cancelación"),
                                              ],
                                            ),
                                            content: const Text(
                                              "¿Estás seguro de que deseas cancelar este pedido?",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.grey.shade600,
                                                ),
                                                child: const Text("No"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  _cancelar(p.id!);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red.shade600,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text("Sí, cancelar"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.expand_more_rounded, 
                                      color: Colors.grey.shade600),
                                ],
                              ),
                              
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    //color: Colors.amber,
                                    gradient: const LinearGradient(
                                      colors: [Color.fromARGB(255, 224, 129, 5), Color.fromARGB(255, 255, 201, 41)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _lineas(p.id!),
                                    builder: (context, s2) {
                                      if (s2.connectionState == ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                      final rows = s2.data ?? [];
                                      if (rows.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.inbox_rounded, 
                                                  color: Colors.grey.shade400, size: 32),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Sin productos',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 12, top: 2),
                                            child: Row(
                                              children: [
                                                Icon(Icons.shopping_bag_rounded, 
                                                    color: Colors.white, size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Productos del pedido'.toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    letterSpacing: 1.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...rows.map((r) {
                                            final nombre = r['producto_nombre'];
                                            final cant = r['cantidad'];
                                            final precio = (r['precio_unitario'] as num).toDouble();
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.fastfood_rounded,
                                                      color: Colors.orange.shade600,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          nombre,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 6, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: Colors.blue.shade100,
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              child: Text(
                                                                'x$cant',
                                                                style: TextStyle(
                                                                  color: Colors.blue.shade700,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              '\$${precio.toStringAsFixed(2)}',
                                                              style: TextStyle(
                                                                color: Colors.green.shade600,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            alignment: Alignment.centerRight,
            child: corteSeleccionado == null 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 Total acumulado actual
                      Text(
                        'TOTAL VENDIDO: \$${totalVentasActual.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(178, 16, 145, 4),
                        ),
                      ),
                      // 🔹 Botón cerrar corte
                      TextButton.icon(
                        style: ButtonStyle(
                          padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                          backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 8, 170, 13)),
                        ),
                        label: const Text(
                          'Cerrar corte',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () async {
                          final totalAntes = totalVentasActual;
                          final idCorte = await DatabaseHelper.instance.cerrarCorte();
                          if (idCorte != null) {
                            showDialog(
                              context: context, 
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, 
                                        color: Colors.green.shade600),
                                    const SizedBox(width: 8),
                                    const Text("Corte cerrado"),
                                  ],
                                ),
                                content: Text(
                                  "El corte ha sido cerrado exitosamente.\nTotal vendido: \$${totalAntes.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _reload();
                                      _loadCortes();
                                      _loadTotalVentasActual();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              ),
                            );
                            widget.graficaKey.currentState?.recargar();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No hay pedidos para cerrar')),
                            );
                          }
                        },
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 8, 131, 14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$ TOTAL:   \$${corteTotalSeleccionado?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
