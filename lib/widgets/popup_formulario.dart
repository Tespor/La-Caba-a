import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:la_cabana/models/consumible.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:la_cabana/models/producto.dart';
import 'package:la_cabana/db/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:la_cabana/controladores/providers/producto_por_categoria_provider.dart';
import 'package:la_cabana/controladores/variables/global_variables.dart' as globals;
import 'package:flutter/services.dart';

Future<T?> mostrarMenuModal<T>(BuildContext context, {Producto? producto}) {
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _FormularioProducto(producto: producto),
      ),
    ),
  );
}



class _FormularioProducto extends StatefulWidget {
  final Producto? producto;
  const _FormularioProducto({this.producto});

  @override
  State<_FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<_FormularioProducto> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  double? _precio;
  String? _descripcion;
  String? _imagenPath;

  bool _guardando = false;

  /// Aquí el Map almacena idConsumible -> cantidad
  final Map<int, int> consumiblesSeleccionados = {};

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(pickedFile.path);
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

    setState(() {
      _imagenPath = savedImage.path;
    });
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _guardando = true);

    final producto = Producto(
      id: widget.producto?.id, // 👈 importante
      nombre: _nombre!,
      precio: _precio!,
      descripcion: _descripcion,
      categoriaId: globals.globalCategoriaSeleccionadaId,
      imagen: _imagenPath,
    );

    final consumiblesConCantidad = consumiblesSeleccionados.entries
        .where((e) => e.value > 0)
        .map((e) => {'id': e.key, 'cantidad': e.value})
        .toList();

    final provider = Provider.of<ProductoxCategoriaProvider>(context, listen: false);

    if (widget.producto == null) {
      // Crear
      final id = await DatabaseHelper.instance.insertarProducto(producto, consumiblesConCantidad);
      producto.id = id;
      provider.agregarProducto(producto);
    } else {
      // Actualizar
      await provider.actualizarProducto(producto, consumiblesConCantidad);
    }

    Navigator.of(context).pop(producto);
  }


  Future<List<Consumible>>? _futureConsumibles;

  @override
  void initState() {
    super.initState();
    _futureConsumibles = DatabaseHelper.instance.obtenerConsumible();

    if (widget.producto != null) {
    _nombre = widget.producto!.nombre;
    _precio = widget.producto!.precio;
    _descripcion = widget.producto!.descripcion;
    _imagenPath = widget.producto!.imagen;
  }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 450),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulario izquierdo
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 12, left: 12),
                child: Column(
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imagenPath == null
                          ? MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color.fromARGB(47, 0, 0, 0),
                                ),
                                width: 100,
                                height: 100,
                                child: const Icon(Icons.camera_alt, size: 40),
                              ),
                            )
                          : Image.file(File(_imagenPath!), width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      initialValue: _nombre,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                      onSaved: (v) => _nombre = v,
                    ),
                      TextFormField(
                        initialValue: _precio?.toString(),
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.number, // teclado numérico
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (v) => v == null || v.isEmpty
                            ? 'Ingrese un precio'
                            : double.tryParse(v) == null
                                ? 'Ingrese un número válido'
                                : null,
                        onSaved: (v) => _precio = double.tryParse(v!),
                      ),
                      TextFormField(
                        initialValue: _descripcion,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onSaved: (v) => _descripcion = v,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black54
                          ),
                          onPressed: _guardando ? null : () => Navigator.pop(context, null),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: _guardando ? null : _guardarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Lista de consumibles con cantidad
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 255, 153, 0), Color.fromARGB(255, 255, 204, 0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Consumibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(228, 255, 255, 255),
                      ),
                    ),
                    Divider(color: const Color.fromARGB(228, 255, 255, 255)),
                    SizedBox(height: 8),
                    FutureBuilder<List<Consumible>>(
                      future: _futureConsumibles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }

                        final lista = snapshot.data ?? [];

                        if (lista.isEmpty) {
                          return const Center(
                            child: Text(
                              "No hay consumibles registrados",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return Expanded(
                          child: ListView.builder(
                            itemCount: lista.length,
                            itemBuilder: (context, i) {
                              final consumible = lista[i];
                              int cantidad = consumiblesSeleccionados[consumible.id] ?? 0;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(220, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      consumible.nombre,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: cantidad > 0
                                              ? () {
                                                  setState(() {
                                                    consumiblesSeleccionados[consumible.id!] = cantidad - 1;
                                                  });
                                                }
                                              : null,
                                          icon: Icon(Icons.remove, size: 20),
                                        ),
                                        Text(cantidad.toString(), style: TextStyle(fontSize: 16)),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              consumiblesSeleccionados[consumible.id!] = cantidad + 1;
                                            });
                                          },
                                          icon: Icon(Icons.add, size: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
