import 'package:flutter/material.dart';
import 'package:la_cabana/widgets/menu_pedidos.dart';
//import 'package:la_cabana/db/database_helper.dart';
import 'package:la_cabana/widgets/nav_categorias.dart';
import 'package:la_cabana/widgets/menu_productos.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    //poblarDatos();
    return Row(
      children: [
        Expanded(
          child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 60),
                    Expanded(child: ProductosGrid()),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: HorizontalRectList(),
                ),
              ],
            ),
        ),
          Container(
            width: 350,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 247, 247, 247),
                  const Color.fromARGB(255, 247, 247, 247),
                  const Color.fromARGB(0, 0, 0, 0)
                ],
                stops: [
                  0.0,
                  0.5,
                  0.7
                ]
              ),
            ),
            child: MenuPedidos()
            )
      ],
    );
  }
}
