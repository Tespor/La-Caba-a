import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:la_cabana/controladores/variables/global_variables.dart';
import 'package:la_cabana/models/producto_pedido.dart';
import 'package:windows_printer/windows_printer.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

// función para cargar imagen desde assets
Future<img.Image> loadLogo() async {
  final data = await rootBundle.load('assets/img/logo.png');
  return img.decodeImage(Uint8List.view(data.buffer))!;
}

Future<void> imprimirTicketEpson({
  required int pedidoId,
  required List<PedidoItem> items,
  required double total,
}) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  final logo = await loadLogo();
  final resizedLogo = img.copyResize(logo, width: 200);
  bytes += generator.image(resizedLogo, align: PosAlign.center);

  final ahora = DateTime.now();
  final fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(ahora);

  bytes += generator.text(
    'Emitido: $fechaHora',
    styles: PosStyles(align: PosAlign.left, bold: true),
  );
  bytes += generator.text(
    'Pedido #$pedidoId',
    styles: PosStyles(
      align: PosAlign.left
    )
  );
  bytes += generator.hr();

  for (var item in items) {
    bytes += generator.row([
      PosColumn(text: item.producto.nombre, width: 6),
      PosColumn(text: '${item.cantidad}x', width: 2),
      PosColumn(text: '\$${item.total.toStringAsFixed(2)}', width: 4, styles: PosStyles(align: PosAlign.right)),
    ]);
  }

  bytes += generator.hr();
  bytes += generator.text(
    'TOTAL: \$${total.toStringAsFixed(2)}',
    styles: PosStyles(align: PosAlign.right, bold: true),
  );
  bytes += generator.feed(2);
  bytes += generator.cut();

  await WindowsPrinter.printRawData(
    printerName: globalImpresora,
    data: Uint8List.fromList(bytes),
    useRawDatatype: true,
  );
}