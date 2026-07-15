import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_almacen/models/herramienta_prestamo.dart';
import 'package:path_provider/path_provider.dart';
import '../models/Usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/auth_service.dart';
import '../services/herramienta_service.dart';
import '../services/herramienta_sync_service.dart';
import '../utils/id_generator.dart';

class HerramientasViewModel extends ChangeNotifier {
  final HerramientaService herramientaService;
  final HerramientaSyncService herramientaSyncService;
  final UsuarioRepository usuarioRepository;
  final AuthService authService;

  HerramientasViewModel({
    required this.herramientaService,
    required this.herramientaSyncService,
    required this.usuarioRepository,
    required this.authService,
  });

  bool _cargando = false;
  bool get cargando => _cargando;

  List<HerramientaPrestamo> _herramientas = [];
  List<HerramientaPrestamo> get herramientas =>
      List.unmodifiable(_herramientas);

  List<Usuario> _usuarios = [];
  List<Usuario> get usuarios => List.unmodifiable(_usuarios);

  bool _soloPrestadas = true;
  bool get soloPrestadas => _soloPrestadas;

  Usuario? _usuarioActual;
  Usuario? get usuarioActual => _usuarioActual;

  void cambiarFiltro(bool value) {
    _soloPrestadas = value;
    cargar();
  }

  Future<void> inicializar() async {
    _usuarioActual = await authService.usuarioActual();
    _usuarios = await usuarioRepository.getAll();
    await cargar();
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    try {
      _herramientas = _soloPrestadas
          ? await herramientaService.obtenerPrestadas()
          : await herramientaService.obtenerTodas();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizar() async {
    _cargando = true;
    notifyListeners();

    try {
      await herramientaSyncService.sincronizarPendientes();
      await herramientaSyncService.descargarHerramientas();
      await cargar();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Abre el selector de archivos, copia la imagen elegida a un
  /// directorio propio de la app y retorna la ruta local resultante.
  /// Retorna null si el usuario cancela.
  Future<String?> seleccionarImagen() async {
    const typeGroup = XTypeGroup(
      label: 'Imágenes',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    final archivo = await openFile(acceptedTypeGroups: [typeGroup]);

    if (archivo == null) return null;

    final directorio = await getApplicationDocumentsDirectory();
    final extension = archivo.name.split('.').last;
    final nombreDestino =
        'herramienta_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final destino = File('${directorio.path}/$nombreDestino');
    final bytes = await archivo.readAsBytes();
    await destino.writeAsBytes(bytes, flush: true);

    return destino.path;
  }

  Future<bool> registrarPrestamo({
    required String nombre,
    String? comentario,
    String? imagenPath,
    required Usuario usuarioDestino,
  }) async {
    if (_usuarioActual == null) return false;

    try {
      final herramienta = HerramientaPrestamo(
        id: IdGenerator.generarValeId(
          nombre: _usuarioActual!.nombre,
          departamento: 'HERRAMIENTA',
        ),
        nombre: nombre,
        comentario: comentario,
        imagenPath: imagenPath,
        usuarioId: usuarioDestino.id ?? '',
        usuarioNombre: usuarioDestino.nombre,
        entregadoPorId: _usuarioActual!.id ?? '',
        entregadoPorNombre: _usuarioActual!.nombre,
        estado: EstadoHerramienta.prestado,
        fechaPrestamo: DateTime.now(),
        syncStatus: 0,
      );

      await herramientaService.registrarPrestamo(herramienta);
      await cargar();

      // Sincronización inmediata best-effort (sube la imagen si hay).
      _sincronizarBestEffort(herramienta.id);

      return true;
    } catch (e) {
      debugPrint('ERROR REGISTRANDO PRESTAMO: $e');
      return false;
    }
  }

  Future<bool> registrarDevolucion(String id) async {
    if (_usuarioActual == null) return false;

    try {
      await herramientaService.registrarDevolucion(
        id: id,
        recibidoPorId: _usuarioActual!.id ?? '',
        recibidoPorNombre: _usuarioActual!.nombre,
      );
      await cargar();
      return true;
    } catch (e) {
      debugPrint('ERROR REGISTRANDO DEVOLUCION: $e');
      return false;
    }
  }

  Future<void> eliminar(String id) async {
    await herramientaService.eliminarHerramienta(id);
    await cargar();
  }

  Future<void> _sincronizarBestEffort(String id) async {
    try {
      await herramientaSyncService.sincronizarPendientes();
    } catch (e) {
      // No bloquea el flujo: la próxima sincronización general lo reintentará.
      debugPrint('SYNC INMEDIATO DE HERRAMIENTA FALLÓ (se reintentará): $e');
    }
  }

  Future<String?> tomarFotografia() async {

    final picker = ImagePicker();

    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) return null;

    final directorio =
    await getApplicationDocumentsDirectory();

    final nombre =
        "herramienta_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final destino = File("${directorio.path}/$nombre");

    await File(foto.path).copy(destino.path);

    return destino.path;
  }
}