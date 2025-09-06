import 'dart:io';
import 'package:flutter/material.dart';
import 'package:la_cabana/controladores/providers/consumible_provider.dart';
import 'package:la_cabana/controladores/providers/controlar_producto_pedido.dart';
import 'package:la_cabana/controladores/providers/theme_provider.dart';
import 'package:la_cabana/controladores/providers/navigation_provider.dart';
import 'package:la_cabana/controladores/variables/global_variables.dart';
import 'package:la_cabana/screens/inventario.dart';
import 'package:la_cabana/screens/administrar.dart';
import 'package:la_cabana/themes/main_themes.dart';
import 'package:provider/provider.dart';
import 'package:la_cabana/screens/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:la_cabana/controladores/providers/producto_por_categoria_provider.dart';
import 'package:windows_printer/windows_printer.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;
  sqfliteFfiInit();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setWindowMinSize(const Size(900, 900));
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeChanger(lightTheme)),
        ChangeNotifierProvider(create: (_) => ProductoxCategoriaProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => ConsumibleProvider()),
      ],
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      Administrador(),
      InventarioScreen(),
    ];
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.getTheme(),
      home: Builder(
        builder: (context) {
          return Scaffold(
            extendBody: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              toolbarHeight: 75,
              //backgroundColor: const Color.fromARGB(255, 255, 234, 157),
              titleSpacing: 0,
              title: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 255, 234, 157),
                      Colors.amber,
                      Colors.amber,
                    ],
                    stops: [
                      0.0,
                      0.5,
                      1.0
                    ]
                  )
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 85,
                      child: Image.asset(
                        'assets/img/logo_text.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    Consumer<NavigationProvider>(
                      builder: (context, nav, _) {
                        return Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Tooltip(
                                message: "Impresoras",
                                child: IconButton(
                                  onPressed: () async {
                                    List<String> listPrinter = await WindowsPrinter.getAvailablePrinters();
                                
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.print,
                                                color: Colors.blue[600],
                                                size: 28,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                "Selecciona una impresora",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            height: 300, // Altura fija para mejor control
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (listPrinter.isEmpty)
                                                  Expanded(
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.print_disabled,
                                                            size: 64,
                                                            color: Colors.grey[400],
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            "No hay impresoras disponibles",
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Expanded(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: listPrinter.length,
                                                      itemBuilder: (_, i) {
                                                        final String impresora = listPrinter[i];
                                                        return Container(
                                                          margin: EdgeInsets.only(bottom: 8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: Colors.grey[300]!,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: ListTile(
                                                            contentPadding: EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                            leading: Container(
                                                              width: 48,
                                                              height: 48,
                                                              decoration: BoxDecoration(
                                                                color: Colors.blue,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Icon(
                                                                Icons.local_printshop,
                                                                color: Colors.white,
                                                                size: 24,
                                                              ),
                                                            ),
                                                            title: Text(
                                                              impresora,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 16,
                                                                color: Colors.grey[800],
                                                              ),
                                                            ),
                                                            subtitle: Text(
                                                              "Toca para seleccionar",
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            trailing: Icon(
                                                              Icons.arrow_forward_ios,
                                                              color: Colors.grey[400],
                                                              size: 16,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            onTap: () {
                                                              globalImpresora = impresora;
                                                              Navigator.pop(context);
                                                              
                                                              // Opcional: Mostrar confirmación
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Row(
                                                                    children: [
                                                                      Icon(Icons.check_circle, color: Colors.white),
                                                                      SizedBox(width: 8),
                                                                      Text("Impresora seleccionada: $impresora"),
                                                                    ],
                                                                  ),
                                                                  backgroundColor: Colors.green,
                                                                  behavior: SnackBarBehavior.floating,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.grey[600],
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              ),
                                              child: Text(
                                                "Cancelar",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  color: Colors.white,
                                  icon: Icon(Icons.print_rounded),
                                ),
                              ),
                            ),
                            _buildNavButton(
                              context,
                              index: 0,
                              currentIndex: nav.currentIndex,
                              icon: Icons.menu_open,
                            ),
                            _buildNavButton(
                              context,
                              index: 1,
                              currentIndex: nav.currentIndex,
                              icon: Icons.admin_panel_settings,
                            ),
                            _buildNavButton(
                              context,
                              index: 2,
                              currentIndex: nav.currentIndex,
                              icon: Icons.inventory,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: Consumer<NavigationProvider>(
              builder: (context, navigationProvider, child) {
                double radius = 28;
                return Container(
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 255, 234, 157),
                      Colors.amber,
                      Colors.amber,
                    ],
                    stops: [
                      0.0,
                      0.5,
                      1.0
                    ]
                  )
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                      ),
                      child: screens[navigationProvider.currentIndex],
                    ),
                  ),
                );
              },
            ),

          );
        },
      ),
    );
  }

  Widget _buildNavButton(BuildContext context,
      {required int index,
      required int currentIndex,
      required IconData icon}) {

    final isSelected = index == currentIndex;

    final List<String> tooltips = [
      "Inicio",
      "Administrar",
      "Inventario",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltips[index],
        waitDuration: Duration(milliseconds: 300),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Provider.of<NavigationProvider>(context, listen: false)
                .setIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 180, 45, 21)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
