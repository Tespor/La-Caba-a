import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:la_cabana/db/database_helper.dart';
import 'package:la_cabana/models/categoria.dart';
import 'package:la_cabana/controladores/providers/producto_por_categoria_provider.dart';
import 'package:provider/provider.dart';
import 'package:la_cabana/controladores/variables/global_variables.dart' as globals;

class HorizontalRectList extends StatefulWidget {
  const HorizontalRectList({super.key});

  @override
  State<HorizontalRectList> createState() => _HorizontalRectListState();
}

class _HorizontalRectListState extends State<HorizontalRectList> {
  final ScrollController _scrollController = ScrollController();
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  List<Categoria> categories = [];
  List<GlobalKey> _itemKeys = [];
  int _selectedIndex = 0;

  bool _estaParaCrear = false;
  final TextEditingController _createCategorie = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  @override
  void dispose() {
    _createCategorie.dispose();
    super.dispose();
  }

  Future<void> _inicializarDatos() async {
    await _cargarCategorias();
    await _cargarProductos();
  }

  Future<void> _cargarCategorias() async {
    final categorias = await DatabaseHelper.instance.obtenerCategorias();
    setState(() {
      categories = categorias;
      _itemKeys = List.generate(categories.length, (_) => GlobalKey());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemKeys.isNotEmpty) _setIndicatorPosition(0);
    });
  }

  Future<void> _cargarProductos() async {
    final productos = await DatabaseHelper.instance.getProductosPorCategoria(
      categories[0].id!,
    );
    if (!mounted) return;
    Provider.of<ProductoxCategoriaProvider>(
      context,
      listen: false,
    ).setProductos(productos);
  }

  Future<void> _actualizarProductosPorCategoria(int index) async {
    setState(() => _selectedIndex = index);
    _setIndicatorPosition(index);

    final productos = await DatabaseHelper.instance.getProductosPorCategoria(
      categories[index].id!,
    );
    if (!mounted) return;

    Provider.of<ProductoxCategoriaProvider>(
      context,
      listen: false,
    ).setProductos(productos);
  }

  void _setIndicatorPosition(int index) {
  final keyContext = _itemKeys[index].currentContext;
  if (keyContext != null) {
    final box = keyContext.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    // Coordenada del scroll
    final scrollBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox;
    final scrollOffset = scrollBox.localToGlobal(Offset.zero);

    setState(() {
      _indicatorLeft = offset.dx - scrollOffset.dx + _scrollController.offset;
      _indicatorWidth = box.size.width;
    });
  }
}


  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _scrollController.jumpTo(_scrollController.offset + event.scrollDelta.dy);
    }
  }

  Future<void> _eliminarCategoria(int index) async {
    final categoria = categories[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Deseas eliminar la categoría "${categoria.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await DatabaseHelper.instance.eliminarCategoria(categoria.id!);
      if (res == null) {
        // No se pudo eliminar porque tiene productos
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No se puede eliminar'),
            content: const Text('Esta categoría contiene productos.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
        return;
      }

      setState(() {
        categories.removeAt(index);
        _itemKeys.removeAt(index);

        if (categories.isEmpty) {
          _selectedIndex = 0;
          globals.globalCategoriaSeleccionadaId = 0;
          Provider.of<ProductoxCategoriaProvider>(context, listen: false)
              .setProductos([]);
        } else {
          if (_selectedIndex >= categories.length) {
            _selectedIndex = categories.length - 1;
          }
          _actualizarProductosPorCategoria(_selectedIndex);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (categories.isNotEmpty) {
          _setIndicatorPosition(_selectedIndex);
          globals.globalCategoriaSeleccionadaId =
              categories[_selectedIndex].id ?? 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 247, 247),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: [
              Row(
                children: [
                  for (int index = 0; index < categories.length; index++)
                    GestureDetector(
                      onTap: () {
                        _actualizarProductosPorCategoria(index);
                        globals.globalCategoriaSeleccionadaId =
                            categories[index].id ?? 0;
                      },
                      onSecondaryTap: () => _eliminarCategoria(index),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          key: _itemKeys[index],
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          height: 60,
                          child: Text(
                            categories[index].nombre,
                            style: TextStyle(
                              color: _selectedIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54,
                              fontSize: 16,
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _estaParaCrear
                      ? Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _createCategorie,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Nueva categoría',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                    ),
                                    contentPadding: EdgeInsets.all(13),
                                    filled: true,
                                    fillColor: const Color.fromARGB(20, 0, 0, 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12), // <-- Aquí el border radius
                                      borderSide: BorderSide.none, // Sin borde visible
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    if (_createCategorie.text.isNotEmpty) {
                                      final nuevaCategoria = Categoria(
                                        nombre: _createCategorie.text,
                                      );
                                      DatabaseHelper.instance
                                          .insertarCategoria(nuevaCategoria)
                                          .then((id) {
                                        setState(() {
                                          nuevaCategoria.id = id;
                                          categories.add(nuevaCategoria);
                                          _itemKeys.add(GlobalKey());
                                          _selectedIndex = categories.length - 1;
                                          _estaParaCrear = false;
                                          _createCategorie.clear();
                                          globals.globalCategoriaSeleccionadaId =
                                              nuevaCategoria.id ?? 0;
                                        });
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          _setIndicatorPosition(_selectedIndex);
                                          _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeOut,
                                          );
                                          _actualizarProductosPorCategoria(
                                              _selectedIndex);
                                        });
                                      });
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Cancelar',
                                onPressed: () {
                                  setState(() => _estaParaCrear = false);
                                  _createCategorie.clear();
                                },
                              ),
                            ],
                          ),
                        )
                      : IconButton(
                          onPressed: () => setState(() => _estaParaCrear = true),
                          tooltip: 'Crear categoría',
                          icon: Icon(
                            Icons.add,
                            size: 30,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ],
              ),
              // Indicador animado dentro del scroll
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _indicatorLeft,
                bottom: 0,
                width: _indicatorWidth,
                height: 3,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
