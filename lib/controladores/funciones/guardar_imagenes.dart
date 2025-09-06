import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<String?> pickAndSaveImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  // Copia la imagen a la carpeta de la app
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = basename(pickedFile.path);
  final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

  return savedImage.path; // Ruta para guardar en la BD
}