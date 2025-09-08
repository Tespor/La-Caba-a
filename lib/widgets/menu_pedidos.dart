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
                        fontSize: 18,
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

                        await imprimirTicketEpson(
                          pedidoId: pedidoId,
                          items: pedidoProvider.items,
                          total: pedidoProvider.totalPedido,
                        );
                        //quiero que esta funcion se ejecute despues de imprimir el ticket
                        pedidoProvider.limpiarCarrito();
                        // mostrar popup de confirmación
                        showDialog(
                          context: context,
                          barrierDismissible: false, // para que no lo cierre el usuario
                          builder: (context) {
                            // cerramos automáticamente después de 2 segundos
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.of(context).pop(true);
                            });

                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text("Cobrado"),
                              content: const Text("✅ Pedido cobrado con éxito"),
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
