import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:la_cabana/controladores/variables/global_variables.dart';
import 'package:windows_printer/windows_printer.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:la_cabana/db/database_helper.dart';

Future<img.Image> loadLogo() async {
  final data = await rootBundle.load('assets/img/logo.png');
  return img.decodeImage(Uint8List.view(data.buffer))!;
}

Future<void> imprimirCorteCaja() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  // 1️⃣ Logo
  final logo = await loadLogo();
  final resizedLogo = img.copyResize(logo, width: 200);
  bytes += generator.image(resizedLogo, align: PosAlign.center);
  bytes += generator.feed(1);

  // 2️⃣ Encabezado
  final ahora = DateTime.now();
  final fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(ahora);
  bytes += generator.text(
    'REPORTE DE CORTE DE CAJA',
    styles: PosStyles(align: PosAlign.center, bold: true),
  );
  bytes += generator.text('Emitido: $fechaHora', styles: PosStyles(align: PosAlign.center));
  bytes += generator.hr();

  // 3️⃣ Obtener ventas del último corte
  final ventas = await DatabaseHelper.instance.obtenerVentasTotalesProductos();

  double totalGeneral = 0;

  for (var item in ventas) {
    final nombre = item['nombre_producto'] ?? 'Producto';
    final cantidad = item['total'] ?? 0;
    final totalDinero = (item['total_dinero'] as num).toDouble();
    totalGeneral += totalDinero;

    // print('$nombre (${cantidad.toString()}x)');
    // print('\$${totalDinero.toStringAsFixed(2)}');

    bytes += generator.row([
      PosColumn(
        text: '$nombre (${cantidad.toString()}x)',
        width: 8,
      ),
      PosColumn(
        text: '\$${totalDinero.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
  }


  bytes += generator.hr();
  // print("____________________________");
  // print('TOTAL VENTA: \$${totalGeneral.toStringAsFixed(2)}');

  // 4️⃣ Total general
  bytes += generator.text(
    'TOTAL VENTA: \$${totalGeneral.toStringAsFixed(2)}',
    styles: PosStyles(align: PosAlign.right, bold: true),
  );

  bytes += generator.feed(2);
  bytes += generator.cut();

  // 5️⃣ Enviar a la impresora
  await WindowsPrinter.printRawData(
    printerName: globalImpresora,
    data: Uint8List.fromList(bytes),
    useRawDatatype: true,
  );
}
