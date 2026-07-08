import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';
import 'package:mi_almacen/services/drive_service.dart';
import 'package:mi_almacen/services/sync_service.dart';
import 'package:mi_almacen/services/vate_sync_service.dart';

class SyncServiceImpl implements SyncService {

  final ProyectoRepository proyectoRepository;
  final MaterialRepository materialRepository;

  final ValeSyncService valeSyncService;
  final CompraSyncService compraSyncService;

  final DriveService driveService;


  SyncServiceImpl({
    required this.proyectoRepository,
    required this.materialRepository,
    required this.valeSyncService,
    required this.compraSyncService,
    required this.driveService,
  });

  @override
  Future<void> sincronizarTodo() async {

    // 1.- Subir información local

    await valeSyncService.sincronizarPendientes();

    await compraSyncService.sincronizarPendientes();

    // 2.- Descargar información del servidor

    await sincronizarProyectos();

    await sincronizarVales();

    await sincronizarCompras();

    await sincronizarMateriales();
  }

  @override
  Future<void> sincronizarProyectos() async {

    await proyectoRepository.sincronizarFirebase();

  }

  @override
  Future<void> sincronizarMateriales() async {

    final excel = await driveService.descargarExcelMateriales();

    await materialRepository.importarDesdeExcel(excel);

  }

  @override
  Future<void> sincronizarVales() async {

    await valeSyncService.descargarVales();

  }

  @override
  Future<void> sincronizarCompras() async {

    await compraSyncService.descargarCompras();

  }

}