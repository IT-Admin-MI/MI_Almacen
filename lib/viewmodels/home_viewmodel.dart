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

  // Ya no valida duplicados, solo verifica que sea un número válido > 0
  bool ordenValido(int orden, List<Proyecto> activos) {
    return orden >= 1 && orden <= activos.length;
  }

  Future<void> actualizarProyecto(Proyecto proyecto) async {
    await proyectoRepository.update(proyecto);
    await proyectoRepository.sincronizarProyectoFirebase(proyecto);
    notifyListeners();
  }

  // Cambia el orden de un proyecto y reordena todos los activos
  Future<List<Proyecto>> cambiarOrden(
      Proyecto proyecto,
      int nuevoOrden,
      List<Proyecto> todos,
      ) async {

    final activos = todos
        .where((p) => p.status)
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));

    activos.removeWhere((p) => p.clave == proyecto.clave);

    final insertIndex = (nuevoOrden - 1).clamp(0, activos.length);
    activos.insert(insertIndex, proyecto);

    // reconstruir lista FINAL correcta
    final reordenados = <Proyecto>[];

    for (int i = 0; i < activos.length; i++) {
      reordenados.add(
        Proyecto(
          clave: activos[i].clave,
          nombre: activos[i].nombre,
          fechaEntrega: activos[i].fechaEntrega,
          orden: i + 1,
          status: true,
        ),
      );
    }

    // SOLO UNA sincronización a Firebase
    await proyectoRepository.sincronizarListaProyectos(reordenados);

    // opcional: update local SQLite si lo necesitas
    for (final p in reordenados) {
      await proyectoRepository.update(p);
    }

    notifyListeners();
    return reordenados;
  }

  Future<List<Proyecto>> desactivarProyecto(
      Proyecto proyecto,
      List<Proyecto> todos,
      ) async {

    final desactivado = Proyecto(
      clave: proyecto.clave,
      nombre: proyecto.nombre,
      fechaEntrega: proyecto.fechaEntrega,
      orden: 0,
      status: false,
    );

    await proyectoRepository.update(desactivado);
    await proyectoRepository.sincronizarProyectoFirebase(desactivado);

    // recalcular activos SIN el proyecto desactivado
    final activos = todos
        .where((p) => p.clave != proyecto.clave && p.status)
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));

    // reordenar correctamente 1..n
    final reordenados = <Proyecto>[];

    for (int i = 0; i < activos.length; i++) {
      reordenados.add(
        Proyecto(
          clave: activos[i].clave,
          nombre: activos[i].nombre,
          fechaEntrega: activos[i].fechaEntrega,
          orden: i + 1,
          status: true,
        ),
      );
    }

    await proyectoRepository.sincronizarListaProyectos(reordenados);
    notifyListeners();
    return reordenados;
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
    await proyectoRepository.sincronizarProyectoFirebase(activado);
    notifyListeners();
    return activado;
  }

  Future<void> sincronizarProyectoFirebase(Proyecto proyecto) async {
    await proyectoRepository.sincronizarProyectoFirebase(proyecto);
  }
}