import 'package:mi_almacen/models/herramienta_prestamo.dart';
import 'package:mi_almacen/services/herramienta_service.dart';

import '../repositories/herramienta_repository.dart';
import 'herramienta_sync_service.dart';

class HerramientaServiceImpl implements HerramientaService {
  final HerramientaRepository herramientaRepository;
  final HerramientaSyncService herramientaSyncService;

  HerramientaServiceImpl({
    required this.herramientaRepository,
    required this.herramientaSyncService,
  });

  @override
  Future<void> registrarPrestamo(HerramientaPrestamo herramienta) async {
    await herramientaRepository.insert(herramienta);
    await herramientaSyncService.sincronizarHerramienta(herramienta);
  }

  @override
  Future<void> registrarDevolucion({
    required String id,
    required String recibidoPorId,
    required String recibidoPorNombre,
  }) async {
    final actual = await herramientaRepository.getById(id);
    if (actual == null) return;

    final actualizada = actual.copyWith(
      estado: EstadoHerramienta.devuelto,
      recibidoPorId: recibidoPorId,
      recibidoPorNombre: recibidoPorNombre,
      fechaDevolucion: DateTime.now(),
      syncStatus: 0,
    );

    await herramientaRepository.update(actualizada);
    await herramientaSyncService.sincronizarHerramienta(actualizada);
  }

  @override
  Future<void> actualizarHerramienta(HerramientaPrestamo herramienta) async {
    final actualizada = herramienta.copyWith(syncStatus: 0);
    await herramientaRepository.update(actualizada);
    await herramientaSyncService.sincronizarHerramienta(actualizada);
  }

  @override
  Future<void> eliminarHerramienta(String id) async {
    await herramientaRepository.delete(id);
    // Nota: si quieres reflejarlo en Firebase, agrega un método
    // eliminarHerramienta en FirebaseService y llámalo aquí.
  }

  @override
  Future<List<HerramientaPrestamo>> obtenerTodas() {
    return herramientaRepository.getAll();
  }

  @override
  Future<List<HerramientaPrestamo>> obtenerPrestadas() {
    return herramientaRepository.getPrestadas();
  }
}