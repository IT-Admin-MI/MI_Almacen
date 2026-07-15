import 'dart:io';
import 'package:mi_almacen/models/herramienta_prestamo.dart';

import '../repositories/herramienta_repository.dart';
import '../services/firebase_service.dart';
import 'image_storage_service.dart';
import 'herramienta_sync_service.dart';

class HerramientaSyncServiceImpl implements HerramientaSyncService {
  final FirebaseService firebaseService;
  final HerramientaRepository herramientaRepository;
  final ImageStorageService imageStorageService;

  HerramientaSyncServiceImpl({
    required this.firebaseService,
    required this.herramientaRepository,
    required this.imageStorageService,
  });

  @override
  Future<bool> sincronizarHerramienta(HerramientaPrestamo herramienta) async {
    try {
      var actual = herramienta;

      // Si hay imagen local pendiente de subir, se sube primero.
      if (actual.imagenUrl == null &&
          actual.imagenPath != null &&
          actual.imagenPath!.isNotEmpty) {
        final archivo = File(actual.imagenPath!);

        if (await archivo.exists()) {
          final url = await imageStorageService.subirImagen(
            herramientaId: actual.id,
            archivo: archivo,
          );

          actual = actual.copyWith(imagenUrl: url);

          // Persistir la URL localmente para no volver a subir la imagen.
          await herramientaRepository.update(actual);
        }
      }

      await firebaseService.guardarHerramienta(actual);
      await herramientaRepository.marcarSincronizado(actual.id);

      return true;
    } catch (e) {
      print('ERROR SINCRONIZANDO HERRAMIENTA: $e');
      return false;
    }
  }

  @override
  Future<void> sincronizarPendientes() async {
    final pendientes =
    await herramientaRepository.getPendientesSincronizacion();

    for (final h in pendientes) {
      await sincronizarHerramienta(h);
    }
  }

  @override
  Future<void> descargarHerramientas() async {
    final remotas = await firebaseService.obtenerHerramientas();
    final idsRemotas = remotas.map((h) => h.id).toSet();

    for (final remota in remotas) {
      final existente = await herramientaRepository.getById(remota.id);

      if (existente == null) {
        await herramientaRepository.insert(remota);
      } else {
        // Conservar imagenPath local si ya existe (la remota no la trae).
        await herramientaRepository.update(
          remota.copyWith(imagenPath: existente.imagenPath),
        );
      }
    }

    final locales = await herramientaRepository.getAll();
    for (final local in locales) {
      if (!idsRemotas.contains(local.id) && local.syncStatus == 1) {
        await herramientaRepository.delete(local.id);
      }
    }
  }
}