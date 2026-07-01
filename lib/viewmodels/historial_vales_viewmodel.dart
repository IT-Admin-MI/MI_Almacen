import 'package:flutter/material.dart';
import 'package:mi_almacen/services/sync_service.dart';

import '../models/Vale.dart';
import '../services/vale_service.dart';

class HistorialValesViewModel extends ChangeNotifier {

  final ValeService valeService;
  String? _usuarioSeleccionado;
  String? _proyectoSeleccionado;

  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  String? get usuarioSeleccionado => _usuarioSeleccionado;
  String? get proyectoSeleccionado => _proyectoSeleccionado;

  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;



  final SyncService syncService;

  HistorialValesViewModel({
    required this.valeService,
    required this.syncService,
  });

  bool _cargando = false;

  bool get cargando => _cargando;

  List<Vale> _todosLosVales = [];

  List<Vale> _vales = [];

  List<Vale> get vales => List.unmodifiable(_vales);

  Future<void> cargarVales() async {

    _cargando = true;
    notifyListeners();

    try {

      _todosLosVales = await valeService.obtenerHistorial();

      _vales = List.from(_todosLosVales);

      _todosLosVales = await valeService.obtenerHistorial();

      print('ViewModel recibió ${_todosLosVales.length} vales');

      _vales = List.from(_todosLosVales);

    } finally {

      _cargando = false;
      notifyListeners();

    }
  }

  void aplicarFiltros(){

    _vales = _todosLosVales.where((vale){

      if(_usuarioSeleccionado != null){

        if(vale.usuarioNombre != _usuarioSeleccionado){

          return false;

        }

      }

      if(_proyectoSeleccionado != null){

        final contieneProyecto = vale.items.any((item){

          return item.proyecto?.clave == _proyectoSeleccionado;

        });

        if(!contieneProyecto){

          return false;

        }

      }

      if(_fechaDesde != null){

        if(vale.fechaCreacion.isBefore(_fechaDesde!)){

          return false;

        }

      }

      if(_fechaHasta != null){

        if(vale.fechaCreacion.isAfter(
          _fechaHasta!.add(
            const Duration(days:1),
          ),
        )){

          return false;

        }

      }

      return true;

    }).toList();

    notifyListeners();

  }

  Future<void> actualizar() async {

    _cargando = true;

    notifyListeners();

    try {

      await syncService.sincronizarVales();

      await cargarVales();

    } finally {

      _cargando = false;

      notifyListeners();

    }

  }
  List<String> get usuarios {

    final lista = _todosLosVales
        .map((v) => v.usuarioNombre)
        .toSet()
        .toList();

    lista.sort();

    return lista;
  }

  List<String> get proyectos {

    final lista = _todosLosVales
        .expand((v) => v.items)
        .where((i) => i.proyecto != null)
        .map((i) => i.proyecto!.clave)
        .toSet()
        .toList();

    lista.sort();

    return lista;
  }

  void seleccionarUsuario(String? usuario){

    _usuarioSeleccionado = usuario;

    aplicarFiltros();
  }

  void seleccionarProyecto(String? proyecto){

    _proyectoSeleccionado = proyecto;

    aplicarFiltros();
  }

  void seleccionarFechaDesde(DateTime? fecha){

    _fechaDesde = fecha;

    aplicarFiltros();
  }

  void seleccionarFechaHasta(DateTime? fecha){

    _fechaHasta = fecha;

    aplicarFiltros();
  }
}