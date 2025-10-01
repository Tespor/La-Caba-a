import 'package:flutter/material.dart';
import 'package:la_cabana/controladores/providers/controlar_producto_pedido.dart';
import 'package:la_cabana/widgets/ticket_printer.dart';
import 'package:provider/provider.dart';

class MenuPedidos extends StatelessWidget {
  const MenuPedidos({super.key});

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
                        final pedidoProvider = context.read<PedidoProvider>();
                        final pedidoId = await pedidoProvider.cobrarPedido();

                        if (pedidoId == -1) {
                          // No hay productos en el pedido
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No hay productos en el pedido'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        await imprimirTicket(
                          pedidoId: pedidoId,
                          items: pedidoProvider.items,
                          total: pedidoProvider.totalPedido,
                        );
                        //quiero que esta funcion se ejecute despues de imprimir el ticket
                        pedidoProvider.limpiarCarrito();
                        // mostrar popup de confirmación
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.7), // Fondo más suave
                          builder: (context) {
                            // Auto-cerrar después de 2.5 segundos
                            Future.delayed(const Duration(milliseconds: 2500), () {
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop(true);
                              }
                            });

                            return Dialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(24),
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
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icono animado
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade400,
                                                  Colors.green.shade600,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.3),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Título con animación
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value.clamp(0.0, 1.0),
                                          child: Transform.translate(
                                            offset: Offset(0, 20 * (1 - value)),
                                            child: Text(
                                              "¡Cobrado!",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade700,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Mensaje con animación
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value.clamp(0.0, 1.0),
                                          child: Transform.translate(
                                            offset: Offset(0, 15 * (1 - value)),
                                            child: Text(
                                              "Pedido cobrado con éxito",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Barra de progreso animada
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 2500),
                                      curve: Curves.linear,
                                      builder: (context, value, child) {
                                        return Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Colors.green.shade100,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: value,
                                            backgroundColor: Colors.transparent,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.green.shade400,
                                            ),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
