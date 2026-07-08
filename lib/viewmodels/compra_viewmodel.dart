import 'package:flutter/cupertino.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/models/Material.dart';
import 'package:mi_almacen/repositories/material_repository.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/repositories/proyecto_repository.dart';

class CompraViewModel extends ChangeNotifier {

  final CompraService compraService;
  final MaterialRepository materialRepository;
  final ProyectoRepository proyectoRepository;

  CompraViewModel({
    required this.compraService,
    required this.materialRepository,
    required this.proyectoRepository,
  });

  String _textoBusqueda = "";

  String get textoBusqueda => _textoBusqueda;

  List<Material> _resultadosBusqueda = [];

  List<Material> get resultadosBusqueda =>
      _resultadosBusqueda;

  bool _loading = false;
  bool get loading => _loading;

  List<Compra> _compras = [];
  List<Compra> get compras => _compras;

  Compra? _compraSeleccionada;
  Compra? get compraSeleccionada => _compraSeleccionada;
  List<Proyecto> _proyectos = [];

  List<Proyecto> get proyectos =>
      _proyectos;


  Future<void> cargarProyectos() async {

    _proyectos =
    await proyectoRepository.getAll();

    notifyListeners();

  }

  Future<void> buscarMaterial(
      String texto,

      ) async {


    _textoBusqueda = texto;
    print("BUSCANDO: ${texto}");

    if (texto.trim().isEmpty) {

      _resultadosBusqueda = [];

      notifyListeners();

      return;
    }


    _resultadosBusqueda =
    await materialRepository.buscar(
      texto,
    );


    notifyListeners();

  }

  void limpiarBusquedaMaterial(){

    _textoBusqueda = "";

    _resultadosBusqueda = [];

    notifyListeners();

  }

  Future<void> cargarCompras() async {

    _loading = true;
    notifyListeners();

    _compras = await compraService.obtenerCompras();

    _loading = false;
    notifyListeners();

  }

  void seleccionarCompra(Compra compra){

    _compraSeleccionada = compra;

    notifyListeners();

  }
  Future<void> crearCompra(Compra compra) async {

    await compraService.crearCompra(compra);

    await cargarCompras();

  }

  Future<void> actualizarCompra(Compra compra) async {

    await compraService.actualizarCompra(compra);

    await cargarCompras();

  }

  Future<void> eliminarCompra(String id) async {

    await compraService.eliminarCompra(id);

    await cargarCompras();

  }

  Future<void> cambiarEstado(
      String id,
      EstadoCompra estado,
      ) async {

    await compraService.cambiarEstado(
      id,
      estado,
    );

    await cargarCompras();

  }

}