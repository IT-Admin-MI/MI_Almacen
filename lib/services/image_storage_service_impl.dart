import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'image_storage_service.dart';

class ImageStorageServiceImpl implements ImageStorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String> subirImagen({
    required String herramientaId,
    required File archivo,
  }) async {
    final extension = archivo.path.split('.').last;

    final ref = storage
        .ref()
        .child('herramientas_prestamo')
        .child('$herramientaId.$extension');

    await ref.putFile(archivo);

    return await ref.getDownloadURL();
  }

  @override
  Future<void> eliminarImagen(String herramientaId) async {
    try {
      final carpeta = storage.ref().child('herramientas_prestamo');
      final listado = await carpeta.listAll();

      for (final item in listado.items) {
        if (item.name.startsWith(herramientaId)) {
          await item.delete();
        }
      }
    } catch (e) {
      print('ERROR ELIMINANDO IMAGEN: $e');
    }
  }
}