import 'package:flutter/material.dart';
import 'package:la_cabana/controladores/providers/consumible_provider.dart';
import 'package:la_cabana/models/consumible.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class InventarioScreen extends StatefulWidget {
  
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<ConsumibleProvider>(context, listen: false).cargarConsumibles()
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 220).floor().clamp(1, 10);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blue[50]!.withOpacity(0.8),
                    Colors.white.withOpacity(0.9),
                    Colors.blue[50]!.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue[100]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[400]!,
                              Colors.blue[600]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Inventario",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Control de stock",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.blue[300]!,
                          Colors.blue[600]!,
                          Colors.blue[300]!,
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ConsumibleProvider>(
                builder: (context, provider, child) {
                  final List<Consumible> consumibles = provider.consumibles;
              
                  if (provider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue[600],
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Cargando inventario...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (consumibles.isEmpty && !provider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.blue[300],
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "No hay consumibles",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Agrega tu primer consumible para comenzar",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => _mostrarDialogoNuevo(context),
                            icon: Icon(Icons.add),
                            label: Text("Agregar Consumible"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      if (consumibles.isNotEmpty)
                        ...consumibles.map((consumible) {
                          return CardConsumible(consumible: consumible);
                        }),
                      // Botón de agregar estilizado
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 243, 243, 243),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(38, 0, 0, 0),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _mostrarDialogoNuevo(context),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Nuevo\nConsumible",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoNuevo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nombreCtrl = TextEditingController();
        TextEditingController cantidadCtrl = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_box,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Nuevo consumible",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    labelText: "Nombre del consumible",
                    prefixIcon: Icon(Icons.inventory_2, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: cantidadCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Cantidad inicial",
                    prefixIcon: Icon(Icons.format_list_numbered, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Cancelar",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();
                final cantidad = int.tryParse(cantidadCtrl.text) ?? 0;

                if (nombre.isNotEmpty) {
                  final nuevo = Consumible(
                    nombre: nombre,
                    cantidad: cantidad,
                  );

                  Provider.of<ConsumibleProvider>(
                    context,
                    listen: false,
                  ).agregarConsumible(nuevo);

                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Consumible agregado: $nombre"),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Guardar",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CardConsumible extends StatefulWidget {
  final Consumible consumible;
  const CardConsumible({
    super.key,
    required this.consumible,
  });

  @override
  State<CardConsumible> createState() => _CardConsumibleState();
}

class _CardConsumibleState extends State<CardConsumible> with SingleTickerProviderStateMixin {
  final TextEditingController numeroCtrl = TextEditingController();
  bool editando = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    numeroCtrl.text = widget.consumible.cantidad.toString();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    numeroCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void guardarCantidad() {
    final cantidad = int.tryParse(numeroCtrl.text) ?? 0;
    Provider.of<ConsumibleProvider>(context, listen: false)
        .actualizarCantidad(widget.consumible.id!, cantidad);

    setState(() {
      editando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Cantidad actualizada: $cantidad"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Color _getStockColor(int cantidad) {
    if (cantidad <= 0) return Colors.red[400]!;
    if (cantidad <= 5) return Colors.orange[400]!;
    return Colors.green[400]!;
  }

  IconData _getStockIcon(int cantidad) {
    if (cantidad <= 0) return Icons.warning;
    if (cantidad <= 5) return Icons.warning_amber;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onSecondaryTap: () => _mostrarDialogoEliminar(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header con icono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Nombre del producto
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        widget.consumible.nombre,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Stock section
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStockColor(widget.consumible.cantidad).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStockColor(widget.consumible.cantidad).withOpacity(0.3),
                        ),
                      ),
                      child: editando
                          ? EnteroTextField(
                              controller: numeroCtrl,
                              label: "Stock",
                              onSubmitted: (_) => guardarCantidad(),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getStockIcon(widget.consumible.cantidad),
                                  color: _getStockColor(widget.consumible.cantidad),
                                  size: 20,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Stock: ${widget.consumible.cantidad}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _getStockColor(widget.consumible.cantidad),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: editando ? Colors.red[50] : Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            editando ? Icons.cancel : Icons.edit,
                            color: editando ? Colors.red[600] : Colors.blue[600],
                          ),
                          iconSize: 20,
                          onPressed: () {
                            setState(() {
                              if (editando) {
                                numeroCtrl.text = widget.consumible.cantidad.toString();
                                editando = false;
                              } else {
                                editando = true;
                              }
                            });
                          },
                        ),
                      ),

                      if (editando)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.save,
                              color: Colors.green[600],
                            ),
                            iconSize: 20,
                            onPressed: guardarCantidad,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEliminar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 28),
            SizedBox(width: 12),
            Text(
              "Eliminar",
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          "¿Estás seguro que deseas eliminar '${widget.consumible.nombre}'?\n\nEsta acción no se puede deshacer.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text("Eliminar"),
          ),
        ],
      ),
    );
    
    if (confirmado != true) return;
    
    final provider = Provider.of<ConsumibleProvider>(context, listen: false);
    final resultado = await provider.eliminarConsumible(widget.consumible.id!);

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Error eliminando consumible"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (resultado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Consumible eliminado"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.link, color: Colors.orange[600]),
              SizedBox(width: 12),
              Text("No se puede eliminar"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Este consumible está siendo usado en:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              ...resultado.map((p) => Container(
                margin: EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p['nombre'] as String),
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Entendido"),
            ),
          ],
        ),
      );
    }
  }
}

class EnteroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onSubmitted;

  const EnteroTextField({
    super.key,
    required this.controller,
    this.label = "Número",
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue[700],
        ),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          labelStyle: TextStyle(
            color: Colors.blue[600],
            fontSize: 12,
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}