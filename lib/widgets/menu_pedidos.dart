import 'package:flutter/material.dart';
import 'package:la_cabana/controladores/providers/controlar_producto_pedido.dart';
import 'package:la_cabana/widgets/ticket_printer.dart';
import 'package:provider/provider.dart';

class MenuPedidos extends StatefulWidget {
  const MenuPedidos({super.key});

  @override
  State<MenuPedidos> createState() => _MenuPedidosState();
}

class _MenuPedidosState extends State<MenuPedidos> {
  @override
  Widget build(BuildContext context) {
    final pedido = Provider.of<PedidoProvider>(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 26),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(54, 0, 0, 0),
              blurRadius: 14,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            /// CONTENIDO PRINCIPAL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tu Pedido",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: pedido.items.length,
                    itemBuilder: (context, index) {
                      final item = pedido.items[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(item.producto.nombre),
                          subtitle: Text(
                            "${item.cantidad} x \$${item.producto.precio.toStringAsFixed(2)}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón para quitar 1 al producto
                              Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(54, 0, 0, 0),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Provider.of<PedidoProvider>(context, listen: false)
                                        .quitarProducto(item.producto);
                                  },
                                  icon: const Text(
                                    '−',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                          
                              // Mostrar total del producto
                              Text(
                                "\$${item.total.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                          
                              // Botón para agrega 1 al producto
                              Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(54, 0, 0, 0),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Provider.of<PedidoProvider>(context, listen: false)
                                        .agregarProducto(item.producto);
                                  },
                                  icon: const Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),


                const Divider(height: 2, color: Colors.black45),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Total: \$${pedido.totalPedido.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 230, 31, 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// BOTÓN COBRAR (arriba a la derecha)
            Positioned(
              right: 0,
              top: 0,
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    onPressed:
                        () => context.read<PedidoProvider>().limpiarCarrito(),
                    icon: Icon(Icons.delete),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (pedido.items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No hay productos en el pedido'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      final controllerMonto = TextEditingController();
                      controllerMonto.text = pedido.totalPedido.toStringAsFixed(2);
                      controllerMonto.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controllerMonto.text.length,
                      );
                      double? pagoCliente;

                      // 🔹 Mostrar modal para ingresar pago
                      final resultado = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return _DialogoPagoAnimado(
                            controllerMonto: controllerMonto,
                            totalPedido: pedido.totalPedido,
                            onPagoConfirmado: (pago) {
                              pagoCliente = pago;
                            },
                          );
                        },
                      );

                      final referencia = resultado?["referencia"];
                      //final esTarjeta = resultado?["esTarjeta"] ?? false;

                      // 🔹 Si no ingresó nada, salimos
                      if (pagoCliente == null) return;

                      final pedidoProvider = context.read<PedidoProvider>();
                      final pedidoId = await pedidoProvider.cobrarPedido(
                        pagoCliente!,
                        referencia: referencia, // 🔹 se envía aquí
                      );


                      if (pedidoId == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No hay productos en el pedido'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // 🔹 Imprimir ticket
                      await imprimirTicket(
                        pedidoId: pedidoId,
                        items: pedidoProvider.items,
                        total: pedidoProvider.totalPedido,
                        pagoCliente: pagoCliente!,
                      );

                      // 🔹 Limpiar carrito
                      pedidoProvider.limpiarCarrito();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 177, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cobrar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎬 Widget del diálogo animado
class _DialogoPagoAnimado extends StatefulWidget {
  final TextEditingController controllerMonto;
  final double totalPedido;
  final Function(double) onPagoConfirmado;

  const _DialogoPagoAnimado({
    required this.controllerMonto,
    required this.totalPedido,
    required this.onPagoConfirmado,
  });

  @override
  State<_DialogoPagoAnimado> createState() => _DialogoPagoAnimadoState();
}

class _DialogoPagoAnimadoState extends State<_DialogoPagoAnimado> {
  double cambio = 0.0;
  bool mostrandoExito = false;

  bool pagoConTarjeta = false; // 🔹 nuevo: controla si se selecciona tarjeta
  final TextEditingController referenciaController = TextEditingController(); // 🔹 para número de referencia

  @override
  void initState() {
    super.initState();
    // Calcular cambio inicial
    final montoInicial = double.tryParse(widget.controllerMonto.text) ?? 0;
    cambio = montoInicial - widget.totalPedido;
  }

  Future<void> _procesarPago() async {
    final text = widget.controllerMonto.text.trim();
    if (text.isEmpty) return;

    final pago = double.tryParse(text);
    if (pago == null) return;

    // 🔹 Validar referencia si es pago con tarjeta
    if (pagoConTarjeta && referenciaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el número de referencia.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validar que el pago sea suficiente
    if (pago < widget.totalPedido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El pago debe ser mayor o igual al total del pedido (\$${widget.totalPedido.toStringAsFixed(2)})',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Mostrar pantalla de éxito
    setState(() {
      mostrandoExito = true;
    });

    // Esperar 2 segundos antes de cerrar
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      widget.onPagoConfirmado(pago);
      Navigator.pop(context, {
        "referencia": pagoConTarjeta ? referenciaController.text.trim() : null,
        "esTarjeta": pagoConTarjeta,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: mostrandoExito
            ? _construirPantallaExito()
            : _construirFormularioPago(),
      ),
    );
  }

  Widget _construirFormularioPago() {
    return IntrinsicWidth(
      child: Container(
        key: const ValueKey('formulario'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ingresar pago del cliente",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Checkbox de pago con tarjeta
            CheckboxListTile(
              title: const Text("Pago con tarjeta"),
              value: pagoConTarjeta,
              onChanged: (valor) {
                setState(() {
                  pagoConTarjeta = valor ?? false;
                  if (pagoConTarjeta) {
                    widget.controllerMonto.text =
                        widget.totalPedido.toStringAsFixed(2);
                    cambio = 0.0; // no hay cambio en tarjeta
                  } else {
                    widget.controllerMonto.clear();
                    referenciaController.clear();
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 10),

            // 🔹 Campo de monto
            TextField(
              controller: widget.controllerMonto,
              enabled: !pagoConTarjeta, // 🔹 deshabilitado si es con tarjeta
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto recibido",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final pagoCliente = double.tryParse(value) ?? 0;
                setState(() {
                  cambio = pagoCliente - widget.totalPedido;
                });
              },
              onSubmitted: (_) => _procesarPago(),
            ),

            const SizedBox(height: 16),

            // 🔹 Campo de referencia (solo visible si es con tarjeta)
            if (pagoConTarjeta)
              TextField(
                controller: referenciaController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Número de referencia",
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 18),

            // 🔹 Mostrar cambio (solo si no es con tarjeta)
            if (!pagoConTarjeta)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cambio >= 0
                      ? "Cambio: \$${cambio.toStringAsFixed(2)}"
                      : "Faltan: \$${(-cambio).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cambio >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 177, 4),
                  ),
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirPantallaExito() {
    return Container(
      key: const ValueKey('exito'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            "¡Cobrado!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Pedido cobrado con éxito",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
