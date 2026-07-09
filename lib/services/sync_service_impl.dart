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
    await _intentar(() => valeSyncService.sincronizarPendientes());
    await _intentar(() => compraSyncService.sincronizarPendientes());
    await _intentar(() => sincronizarProyectos());
    await _intentar(() => sincronizarVales());
    await _intentar(() => sincronizarCompras());
    //await _intentar(() => sincronizarMateriales());
  }

  Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (e) {
      print('ERROR EN SYNC: $e');
    }
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