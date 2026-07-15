import 'dart:io';

abstract class ImageStorageService {
  /// Sube el archivo local a Firebase Storage bajo una ruta única
  /// asociada a la herramienta, y retorna la URL de descarga.
  Future<String> subirImagen({
    required String herramientaId,
    required File archivo,
  });

  Future<void> eliminarImagen(String herramientaId);
}