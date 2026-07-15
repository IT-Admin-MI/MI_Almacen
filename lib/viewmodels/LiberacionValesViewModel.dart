import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/repositories/vale_repository.dart';
import 'package:mi_almacen/services/firebase_service.dart';

class LiberacionValesViewModel extends ChangeNotifier {
  final ValeRepository valeRepository;
  final ProyectoRepository proyectoRepository;
  final FirebaseService firebaseService;

  LiberacionValesViewModel({
    required this.valeRepository,
    required this.proyectoRepository,
    required this.firebaseService,
  });

  bool _cargando = false;
  bool get cargando => _cargando;

  List<Vale> _todosLosVales = [];
  List<Vale> _vales = [];
  List<Vale> get vales => _vales;

  List<Proyecto> _proyectos = [];
  List<Proyecto> get proyectos => _proyectos;

  Proyecto? _proyectoSeleccionado;
  Proyecto? get proyectoSeleccionado => _proyectoSeleccionado;

  DateTime? _fechaInicio;
  DateTime? get fechaInicio => _fechaInicio;

  DateTime? _fechaFin;
  DateTime? get fechaFin => _fechaFin;

  Future<void> cargarVales() async {
    _cargando = true;
    notifyListeners();

    _proyectos = await proyectoRepository.getAll();

    _todosLosVales =
    await valeRepository.getPendientesLiberacion();

    aplicarFiltros();

    _cargando = false;
    notifyListeners();
  }

  Future<void> actualizar() async {
    await cargarVales();
  }

  void seleccionarProyecto(Proyecto? proyecto) {
    _proyectoSeleccionado = proyecto;
    aplicarFiltros();
  }

  void seleccionarFechaInicio(DateTime? fecha) {
    _fechaInicio = fecha;
    aplicarFiltros();
  }

  void seleccionarFechaFin(DateTime? fecha) {
    _fechaFin = fecha;
    aplicarFiltros();
  }

  void limpiarFiltros() {
    _proyectoSeleccionado = null;
    _fechaInicio = null;
    _fechaFin = null;
    aplicarFiltros();
  }

  void aplicarFiltros() {
    _vales = _todosLosVales.where((vale) {
      /// Proyecto
      if (_proyectoSeleccionado != null) {
        final existe = vale.items.any(
              (item) =>
          item.proyecto?.clave ==
              _proyectoSeleccionado!.clave,
        );

        if (!existe) return false;
      }

      /// Fecha inicio
      if (_fechaInicio != null) {
        if (vale.fechaCreacion.isBefore(_fechaInicio!)) {
          return false;
        }
      }

      /// Fecha fin
      if (_fechaFin != null) {
        final limite = DateTime(
          _fechaFin!.year,
          _fechaFin!.month,
          _fechaFin!.day,
          23,
          59,
          59,
        );

        if (vale.fechaCreacion.isAfter(limite)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  Future<bool> actualizarLiberacionVale({
    required String valeId,
    required int liberado,
    String? comentario,
  }) async {
    try {
      await valeRepository.actualizarLiberacionVale(
        valeId: valeId,
        liberado: liberado,
      );

      await firebaseService.actualizarLiberacionVale(


        id: valeId,
        liberado: liberado,
        comentario: comentario,
        liberadoPor: "ALMACENISTA",
      );

      await cargarVales();

      return true;
    } catch (e) {
      debugPrint('Error al actualizar liberación del vale: $e');
      return false;
    }
  }
}