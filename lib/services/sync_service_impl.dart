import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/services/drive_service.dart';
import 'package:mi_almacen/services/vate_sync_service.dart';

import '../repositories/proyecto_repository.dart';
import 'sync_service.dart';


class SyncServiceImpl
    implements SyncService {

  final ProyectoRepository
  proyectoRepository;

  final MaterialRepository materialRepository;

  final DriveService driveService;

  final ValeSyncService valeSyncService;

  SyncServiceImpl({
    required this.proyectoRepository,
    required this.materialRepository,
    required this.driveService,
    required this.valeSyncService,
  });

  @override
  Future<void> sincronizarTodo() async {

    await sincronizarProyectos();
  }

  @override
  Future<void> sincronizarProyectos() async {

    await proyectoRepository
        .sincronizarFirebase();
  }

  @override
  Future<void> sincronizarMateriales() async {

    final excelPath =
    await driveService
        .descargarExcelMateriales();

    await materialRepository
        .importarDesdeExcel(
      excelPath,
    );
  }

  @override
  Future<void> sincronizarVales() async {

    try {

      await valeSyncService.descargarVales();

    } catch (_) {
      // Sin conexión o error.
      // No hacemos nada porque la aplicación debe seguir funcionando
      // con SQLite.
    }

  }
}