import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';
import 'package:mi_almacen/repositories/vale_repository.dart';
import 'package:mi_almacen/services/excel_service.dart';

class HistorialLiberacionesViewModel extends ChangeNotifier {
  final ValeRepository valeRepository;
  final ProyectoRepository proyectoRepository;
  final ExcelService excelExportService;

  HistorialLiberacionesViewModel({
    required this.valeRepository,
    required this.proyectoRepository,
    required this.excelExportService,
  });

  bool _cargando = false;
  bool get cargando => _cargando;

  bool _exportando = false;
  bool get exportando => _exportando;

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

  Future<void> cargarHistorial() async {
    _cargando = true;
    notifyListeners();

    _proyectos = await proyectoRepository.getAll();
    _todosLosVales = await valeRepository.getHistorialLiberados();

    aplicarFiltros();

    _cargando = false;
    notifyListeners();
  }

  Future<void> actualizar() => cargarHistorial();

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
      if (_proyectoSeleccionado != null) {
        final existe = vale.items.any(
              (item) => item.proyecto?.clave == _proyectoSeleccionado!.clave,
        );
        if (!existe) return false;
      }

      if (_fechaInicio != null && vale.fechaCreacion.isBefore(_fechaInicio!)) {
        return false;
      }

      if (_fechaFin != null) {
        final limite = DateTime(
          _fechaFin!.year, _fechaFin!.month, _fechaFin!.day, 23, 59, 59,
        );
        if (vale.fechaCreacion.isAfter(limite)) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  Future<Uint8List> exportarExcel() async {
    _exportando = true;
    notifyListeners();

    try {
      return await excelExportService.exportarVales(_vales);
    } finally {
      _exportando = false;
      notifyListeners();
    }
  }
}