import 'package:flutter/material.dart';
import '../models/Proyecto.dart';
import '../repositories/proyecto_repository.dart';

class HomeViewModel extends ChangeNotifier {

  final ProyectoRepository proyectoRepository;

  HomeViewModel({required this.proyectoRepository});

  bool _mostrarTodos = false;
  bool get mostrarTodos => _mostrarTodos;

  void cambiarMostrarTodos(bool value) {
    _mostrarTodos = value;
    notifyListeners();
  }

  // Valida que el orden no esté en uso por otro proyecto
  bool ordenDisponible(List<Proyecto> proyectos, int orden, String claveActual) {
    return !proyectos.any((p) => p.orden == orden && p.clave != claveActual);
  }

  Future<void> actualizarProyecto(Proyecto proyecto) async {
    await proyectoRepository.update(proyecto);
    notifyListeners();
  }

  // "Eliminar" = desactivar status
  Future<void> desactivarProyecto(Proyecto proyecto, List<Proyecto> todos) async {
    // Desactivar con orden -1
    final desactivado = Proyecto(
      clave: proyecto.clave,
      nombre: proyecto.nombre,
      fechaEntrega: proyecto.fechaEntrega,
      orden: -1,
      status: false,
    );
    await proyectoRepository.update(desactivado);

    // Reordenar activos restantes compactando huecos
    final activos = todos
        .where((p) => p.clave != proyecto.clave && p.status)
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));

    for (int i = 0; i < activos.length; i++) {
      final reordenado = Proyecto(
        clave: activos[i].clave,
        nombre: activos[i].nombre,
        fechaEntrega: activos[i].fechaEntrega,
        orden: i + 1,
        status: true,
      );
      await proyectoRepository.update(reordenado);
    }

    notifyListeners();
  }

  Future<Proyecto> activarProyecto(Proyecto proyecto, List<Proyecto> todos) async {
    final totalActivos = todos.where((p) => p.status).length;
    final activado = Proyecto(
      clave: proyecto.clave,
      nombre: proyecto.nombre,
      fechaEntrega: proyecto.fechaEntrega,
      orden: totalActivos + 1,
      status: true,
    );
    await proyectoRepository.update(activado);
    notifyListeners();
    return activado;
  }
  Future<void> sincronizarProyectoFirebase(Proyecto proyecto) async {
    await proyectoRepository.sincronizarProyectoFirebase(proyecto);
  }
}