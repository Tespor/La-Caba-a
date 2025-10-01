import 'package:flutter/material.dart';
import 'package:la_cabana/widgets/grafica.dart';
import 'package:la_cabana/widgets/historial_pedidos.dart';

class Administrador extends StatefulWidget {
  const Administrador({super.key});

  @override
  State<Administrador> createState() => _AdministradorState();
}

class _AdministradorState extends State<Administrador> {
  final graficaKey = GlobalKey<GraficaState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determinamos si la pantalla es ancha (>1000px)
          //final bool isWide = constraints.maxWidth > 1000;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 750, maxHeight: 600),
                      child: Container(
                        margin: const EdgeInsets.only(top: 18.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: HistorialPedidos(graficaKey: graficaKey)
                          ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
                      child: Container(
                        margin: const EdgeInsets.only(top: 18.0, bottom: 18.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Grafica(key: graficaKey)
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
