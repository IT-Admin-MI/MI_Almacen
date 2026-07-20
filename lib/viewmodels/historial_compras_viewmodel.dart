import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/repositories/usuario_repository.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';

class HistorialComprasViewModel extends ChangeNotifier {
  final CompraService compraService;
  final CompraSyncService compraSyncService;
  final UsuarioRepository usuarioRepository;

  HistorialComprasViewModel({
    required this.compraService,
    required this.compraSyncService,
    required this.usuarioRepository,
  });

  bool _cargando = false;
  bool get cargando => _cargando;

  List<Compra> _todasLasCompras = [];
  List<Compra> _compras = [];
  List<Compra> get compras => List.unmodifiable(_compras);

  Map<String, String> _nombresUsuarios = {};
  String nombreComprador(String compradorId) {
    return _nombresUsuarios[compradorId] ?? compradorId;
  }

  String? _compradorSeleccionado;
  String? _proyectoSeleccionado;
  EstadoCompra? _estadoSeleccionado;

  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  String? get compradorSeleccionado => _compradorSeleccionado;
  String? get proyectoSeleccionado => _proyectoSeleccionado;
  EstadoCompra? get estadoSeleccionado => _estadoSeleccionado;

  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;

  Future<void> cargarCompras() async {
    _cargando = true;
    notifyListeners();

    try {
      _todasLasCompras = await compraService.obtenerCompras();
      _compras = List.from(_todasLasCompras);

      final usuarios = await usuarioRepository.getAll();
      _nombresUsuarios = {
        for (final u in usuarios)
          if (u.id != null) u.id!: u.nombre,
      };

      aplicarFiltros();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizar() async {
    _cargando = true;
    notifyListeners();

    try {
      await compraSyncService.descargarCompras();
      await compraSyncService.sincronizarPendientes();
      await cargarCompras();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void aplicarFiltros() {
    _compras = _todasLasCompras.where((compra) {
      if (_compradorSeleccionado != null) {
        if (compra.compradorId != _compradorSeleccionado) {
          return false;
        }
      }

      if (_proyectoSeleccionado != null) {
        final contieneProyecto = compra.items.any(
              (item) => item.proyectoClave == _proyectoSeleccionado,
        );
        if (!contieneProyecto) {
          return false;
        }
      }

      if (_estadoSeleccionado != null) {
        if (compra.estado != _estadoSeleccionado) {
          return false;
        }
      }

      if (_fechaDesde != null) {
        if (compra.fechaSolicitud.isBefore(_fechaDesde!)) {
          return false;
        }
      }

      if (_fechaHasta != null) {
        if (compra.fechaSolicitud.isAfter(
          _fechaHasta!.add(const Duration(days: 1)),
        )) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  List<String> get compradores {
    final lista = _todasLasCompras
        .map((c) => c.compradorId)
        .toSet()
        .toList();

    lista.sort((a, b) => nombreComprador(a).compareTo(nombreComprador(b)));

    return lista;
  }

  List<String> get proyectos {
    final lista = _todasLasCompras
        .expand((c) => c.items)
        .where((i) => i.proyectoClave != null)
        .map((i) => i.proyectoClave!)
        .toSet()
        .toList();

    lista.sort();

    return lista;
  }

  void seleccionarComprador(String? compradorId) {
    _compradorSeleccionado = compradorId;
    aplicarFiltros();
  }

  void seleccionarProyecto(String? proyecto) {
    _proyectoSeleccionado = proyecto;
    aplicarFiltros();
  }

  void seleccionarEstado(EstadoCompra? estado) {
    _estadoSeleccionado = estado;
    aplicarFiltros();
  }

  void seleccionarFechaDesde(DateTime? fecha) {
    _fechaDesde = fecha;
    aplicarFiltros();
  }

  void seleccionarFechaHasta(DateTime? fecha) {
    _fechaHasta = fecha;
    aplicarFiltros();
  }

  void limpiarFiltros() {
    _compradorSeleccionado = null;
    _proyectoSeleccionado = null;
    _estadoSeleccionado = null;
    _fechaDesde = null;
    _fechaHasta = null;
    aplicarFiltros();
  }
}