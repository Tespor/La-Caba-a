import 'dart:io';

import 'package:flutter/material.dart';
import 'package:la_cabana/controladores/providers/controlar_producto_pedido.dart';
import 'package:la_cabana/models/producto.dart';
import 'package:la_cabana/controladores/providers/producto_por_categoria_provider.dart';
import 'package:provider/provider.dart';
import 'package:la_cabana/widgets/popup_formulario.dart';


class ProductosGrid extends StatelessWidget {
  const ProductosGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor().clamp(1, 10);

    return Consumer<ProductoxCategoriaProvider>(
      builder: (context, provider, child) {
        final List<Producto> productos = provider.productos;

        return Container(
          margin: const EdgeInsets.only(top: 16.0),
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            childAspectRatio: 0.85,
            clipBehavior: Clip.none,
            children: [
              if(productos.isNotEmpty)
                ...productos.map((producto) => HoverGlowCard(product: producto)),//.toList(),
              AddProductCard(
                onPressed: () => mostrarMenuModal(context),
              ),
            ]
          ),
        );
      },
    );
  }
}



class HoverGlowCard extends StatefulWidget {
  final Producto product;

  const HoverGlowCard({super.key, required this.product});

  @override
  State<HoverGlowCard> createState() => _HoverGlowCardState();
}

class _HoverGlowCardState extends State<HoverGlowCard> {
  bool _hovering = false;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
  bool existeImagen = widget.product.imagen != null && widget.product.imagen!.isNotEmpty;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () async {
          final agregado = await Provider.of<PedidoProvider>(
            context,
            listen: false,
          ).agregarProducto(widget.product);

          if (!agregado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay consumibles suficientes para este producto'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onSecondaryTapDown: (details) {
          _tapPosition = details.globalPosition;
        },
        onSecondaryTap: () async {
          if (_tapPosition == null) return;

          final selected = await showMenu<String>(
            color: Theme.of(context).colorScheme.primary,
            context: context,
            position: RelativeRect.fromLTRB(
              _tapPosition!.dx,
              _tapPosition!.dy,
              _tapPosition!.dx,
              _tapPosition!.dy,
            ),
            items: [
              PopupMenuItem(
                value: 'actualizar', 
                child: onsecondarytap_menu_items(texto: 'Actualizar', icono: Icons.sync)
                ),
              const PopupMenuItem(
                value: 'eliminar', 
                child: onsecondarytap_menu_items(texto: 'Eliminar', icono: Icons.delete)
                ),
            ],
          );

          if (selected == 'actualizar') {
            final actualizado = await mostrarMenuModal(
              context,
              producto: widget.product,
            );

            if (actualizado != null && actualizado is Producto) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Producto actualizado correctamente")),
              );
            }
          } else if (selected == 'eliminar'){
            final confirmar = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Confirmar eliminación"),
                  content: Text(
                    "¿Seguro que deseas eliminar el producto \"${widget.product.nombre}\"?",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(
                          color: Colors.white
                        ),
                        ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (confirmar == true) {
              final provider = Provider.of<ProductoxCategoriaProvider>(
                context,
                listen: false,
              );

              await provider.eliminarProducto(widget.product.id!);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Producto eliminado correctamente")),
              );
            }
          }
        },
        //Contenedor de la tarjeta
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          //padding: const EdgeInsets.all(8),//hay que borrar
          decoration: BoxDecoration(
            color: _hovering ? Colors.white : Colors.white70,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AnimatedScale(
                    scale: _hovering ? 1.2 : 1, 
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: existeImagen ?
                      Image.memory(
                        widget.product.imagen!,// Uint8List directo
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                    ) 
                    : Container(color: Colors.grey.shade200,),
                  ),
                )
              ),
              //Parte de abajo de la tarjeta
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: _hovering ? Colors.white : const Color.fromARGB(255, 240, 240, 240),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                widget.product.nombre,
                                style: const TextStyle(
                                  color: Color.fromARGB(169, 0, 0, 0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 6,),
                              Text(
                                '\$${widget.product.precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 197, 10, 10),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class onsecondarytap_menu_items extends StatelessWidget {
  final String texto;
  final IconData icono;

  const onsecondarytap_menu_items({
    super.key,
    required this.texto,
    required this.icono
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Icon(
            icono,
            color: Colors.white,
          ),
          SizedBox(width: 10,),
          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w200
            ),
            ),
        ],
      ),
      );
  }
}



class AddProductCard extends StatefulWidget {
  final VoidCallback onPressed;

  const AddProductCard({super.key, required this.onPressed});

  @override
  State<AddProductCard> createState() => _AddProductCardState();
}

class _AddProductCardState extends State<AddProductCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: _hovering ? Colors.white : Colors.white70,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}