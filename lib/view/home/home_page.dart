import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mi_almacen/constants/roles.dart';
import 'package:mi_almacen/repositories/compra_repository.dart';
import 'package:mi_almacen/repositories/usuario_repository.dart';
import 'package:mi_almacen/services/compra_service.dart';
import 'package:mi_almacen/services/compra_solicitud_sync_service.dart';
import 'package:mi_almacen/services/compra_sync_service.dart';
import 'package:mi_almacen/view/admin/admin_db_page.dart';
import 'package:mi_almacen/view/compras/compras_page.dart';
import 'package:mi_almacen/view/compras/compras_seguimiento_page.dart';
import 'package:mi_almacen/view/compras/historial_compras_page.dart';
import 'package:mi_almacen/view/herramientas/herramientas_page.dart';
import 'package:mi_almacen/view/vales/historial_vales_page.dart';
import 'package:mi_almacen/view/vales/liberacionValesPage.dart';
import 'package:mi_almacen/view/vales/vales_page.dart';
import 'package:mi_almacen/viewmodels/LiberacionValesViewModel.dart';
import 'package:mi_almacen/viewmodels/admin_db_viewmodel.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/herramientas_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_compras_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/compra_viewmodel.dart';
import 'package:mi_almacen/viewmodels/seguimiento_compras_viewmodel.dart';
import 'package:mi_almacen/viewmodels/vale_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';

import '../../models/Proyecto.dart';
import '../../models/Usuario.dart';
import '../vales/vales_aprobacion_page.dart';
import '../../repositories/proyecto_repository.dart';

import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {

  final AuthService authService;

  final CompraSyncService compraSyncService;

  final CompraService compraService;

  final UsuarioRepository usuarioRepository;

  final ProyectoRepository proyectoRepository;

  final ValeViewModel valeViewModel;

  final AprobacionValesViewModel aprobacionValesViewModel;

  final HomeViewModel homeViewModel;

  final HistorialValesViewModel historialValesViewModel;

  final CompraViewModel compraViewModel;

  final LiberacionValesViewModel liberacionValesViewModel;

  final AdminDbViewModel adminDbViewModel;

  final CompraRepository compraRepository;

  final HerramientasViewModel herramientasViewModel;

  final HistorialComprasViewModel historialComprasViewModel;


  final CompraSolicitudSyncService compraSolicitudSyncService;

  const HomePage({
    super.key,
    required this.authService,
    required this.proyectoRepository,
    required this.valeViewModel,
    required  this.aprobacionValesViewModel,
    required this.homeViewModel,
    required this.historialValesViewModel,
    required this.liberacionValesViewModel,
    required this.adminDbViewModel,
    required this.compraViewModel,
    required this.compraRepository,
    required this.compraSyncService,
    required this.compraSolicitudSyncService,
    required this.herramientasViewModel,
    required this.usuarioRepository,
    required this.historialComprasViewModel,
    required this.compraService,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}
class _HomePageState
    extends State<HomePage> {

  bool get esAdmin =>
      usuario?.rol == 0;

  bool get esSupervisor =>
      usuario?.rol == 1;

  bool get esComprador =>
      usuario?.rol == 2;

  bool get esAlmacenista =>
      usuario?.rol == 3;

  bool get esEmpleado =>
      usuario?.rol == 4;

  Usuario? usuario;

  List<Proyecto> proyectos = [];

  bool cargandoProyectos = true;

  @override
  void initState() {
    super.initState();

    cargarUsuario();
    cargarProyectos();

    FirebaseMessaging.instance.getToken().then((token) {
      print('TOKEN ACTUAL DEL DISPOSITIVO: $token');
    });
  }

  Color _colorParaOrden(int orden, int totalActivos) {
    if (totalActivos <= 1) return const Color(0xFF2ecc71);

    final t = ((orden - 1) / (totalActivos - 1)).clamp(0.0, 1.0);

    const rojo = Color(0xFFe74c3c);
    const amarillo = Color(0xFFf1c40f);
    const verde = Color(0xFF2ecc71);

    return t <= 0.5
        ? Color.lerp(rojo, amarillo, t / 0.5)!
        : Color.lerp(amarillo, verde, (t - 0.5) / 0.5)!;
  }

  Future<void> cargarUsuario() async {

    final resultado =
    await widget.authService
        .usuarioActual();

    print(
      'HOME USER => '
          'nombre=${resultado?.nombre} '
          'rol=${resultado?.rol} '
          'departamento=${resultado?.departamento}',
    );

    if (!mounted) return;

    setState(() {
      usuario = resultado;
    });
  }

  Future<void> cargarProyectos() async {

    print('CARGAR PROYECTOS');

    var resultado =
    await widget.proyectoRepository.getAll();

    print(
      'PROYECTOS EN SQLITE: ${resultado.length}',
    );

    if (resultado.isEmpty) {

      print(
        'SQLITE VACIO, SINCRONIZANDO...',
      );

      await widget.proyectoRepository
          .sincronizarFirebase();

      resultado =
      await widget.proyectoRepository
          .getAll();

      print(
        'PROYECTOS DESPUES DE SINCRONIZAR: ${resultado.length}',
      );
    }

    resultado.sort((a, b) {
      if (a.status != b.status) return a.status ? -1 : 1;
      return a.orden.compareTo(b.orden);
    });

    if (!mounted) return;

    setState(() {

      proyectos = resultado;

      cargandoProyectos = false;
    });

  }
  Future<void> cerrarSesion() async {

    await widget.authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
  void _reordenarLista() {
    proyectos.sort((a, b) {
      if (a.status != b.status) return a.status ? -1 : 1;
      if (!a.status) return 0;
      return a.orden.compareTo(b.orden);
    });
  }

  void _agregarGrupo(List<Widget> menu, List<Widget> grupo) {
    if (grupo.isEmpty) return;

  //  if (menu.isNotEmpty) {
  //    menu.add(const Divider());
  //  }

    menu.addAll(grupo);
  }

  Future<void> _mostrarDialogoEdicion(Proyecto proyecto) async {
    bool isSaving = false;
    final nombreCtrl = TextEditingController(text: proyecto.nombre);
    final ordenCtrl = TextEditingController(text: proyecto.orden.toString());
    DateTime? fechaEntrega = proyecto.fechaEntrega;
    bool status = proyecto.status;
    String? errorOrden;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Editar: ${proyecto.clave}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // NOMBRE
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // FECHA ENTREGA
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fechaEntrega != null
                                ? 'Entrega: ${formatearFecha(fechaEntrega!)}'
                                : 'Sin fecha de entrega',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: fechaEntrega ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => fechaEntrega = picked);
                            }
                          },
                          child: const Text('Seleccionar'),
                        ),
                        if (fechaEntrega != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setDialogState(() => fechaEntrega = null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // STATUS
                    SwitchListTile(
                      title: Text(status ? 'Activo' : 'Inactivo'),
                      value: status,
                      onChanged: (val) => setDialogState(() => status = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setDialogState(() => isSaving = true);
                    final actualizado = Proyecto(
                      clave: proyecto.clave,
                      nombre: nombreCtrl.text.trim(),
                      orden: proyecto.orden, // se mantiene, orden solo cambia al activar/desactivar
                      status: status,
                      tipo:proyecto.tipo,
                      fechaEntrega: fechaEntrega,
                    );

                    if (status == false && proyecto.status == true) {
                      // Desactivando: orden → 0 y recompactar activos
                      final nuevosActivos =
                      await widget.homeViewModel.desactivarProyecto(proyecto, proyectos);

                      final desactivado = Proyecto(
                        clave: proyecto.clave,
                        nombre: nombreCtrl.text.trim(),
                        orden: 0,
                        status: false,
                        fechaEntrega: fechaEntrega,
                      );

                      setState(() {
                        proyectos.removeWhere((p) => p.clave == proyecto.clave);
                        proyectos.add(desactivado); // ← se re-agrega como inactivo

                        for (final p in nuevosActivos) {
                          final i = proyectos.indexWhere((x) => x.clave == p.clave);
                          if (i != -1) {
                            proyectos[i] = p;
                          } else {
                            proyectos.add(p);
                          }
                        }

                        _reordenarLista();
                      });
                    } else if (status == true && proyecto.status == false) {
                      // Activando: asignar orden = activos + 1
                      final activado = await widget.homeViewModel.activarProyecto(
                        Proyecto(
                          clave: proyecto.clave,
                          nombre: nombreCtrl.text.trim(),
                          fechaEntrega: fechaEntrega,
                          orden: -1,
                          status: true,
                        ),
                        proyectos,
                      );
                      setState(() {
                        final i = proyectos.indexWhere((p) => p.clave == proyecto.clave);
                        if (i != -1) proyectos[i] = activado;
                        _reordenarLista();
                      });
                    } else {
                      // Solo cambio de nombre/fecha
                      await widget.homeViewModel.actualizarProyecto(actualizado);
                      setState(() {
                        final i = proyectos.indexWhere((p) => p.clave == proyecto.clave);
                        if (i != -1) proyectos[i] = actualizado;
                        _reordenarLista();
                      });
                    }

                    if (mounted) Navigator.pop(context);
                  },

                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDialogoNuevoProyecto() async {
    final claveCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    DateTime? fechaEntrega;
    String? errorClave;
    String? errorNombre;
    String? errorOrden;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Proyecto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextFormField(
                      controller: claveCtrl,
                      decoration: InputDecoration(
                        labelText: 'Clave',
                        border: const OutlineInputBorder(),
                        errorText: errorClave,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: const OutlineInputBorder(),
                        errorText: errorNombre,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fechaEntrega != null
                                ? 'Entrega: ${formatearFecha(fechaEntrega!)}'
                                : 'Sin fecha de entrega',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => fechaEntrega = picked);
                            }
                          },
                          child: const Text('Seleccionar'),
                        ),
                        if (fechaEntrega != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setDialogState(() => fechaEntrega = null),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool valido = true;

                    final clave = claveCtrl.text.trim();
                    final nombre = nombreCtrl.text.trim();
                    if (clave.isEmpty) {
                      setDialogState(() => errorClave = 'Ingresa una clave');
                      valido = false;
                    } else if (proyectos.any((p) => p.clave == clave)) {
                      setDialogState(() => errorClave = 'Esta clave ya existe');
                      valido = false;
                    } else {
                      setDialogState(() => errorClave = null);
                    }

                    if (nombre.isEmpty) {
                      setDialogState(() => errorNombre = 'Ingresa un nombre');
                      valido = false;
                    } else {
                      setDialogState(() => errorNombre = null);
                    }

                    if (!valido) return;

                    final ordenAuto = proyectos.where((p) => p.status).length + 1;

                    final nuevo = Proyecto(
                      clave: clave,
                      nombre: nombre,
                      orden: ordenAuto,
                      status: true,
                      tipo:1,

                      fechaEntrega: fechaEntrega,
                    );

                    await widget.proyectoRepository.insert(nuevo);
                    await widget.homeViewModel.sincronizarProyectoFirebase(nuevo);

                    setState(() {
                      proyectos.add(nuevo);
                      proyectos.sort((a, b) {
                        if (a.status != b.status) return a.status ? -1 : 1;
                        return a.orden.compareTo(b.orden);
                      });
                    });

                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String formatearFecha(
      DateTime fecha,
      ) {

    return
      '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
  }
  Color _colorFechaEntrega(DateTime? fechaEntrega) {
    if (fechaEntrega == null) return Colors.grey;

    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final entrega = DateTime(
      fechaEntrega.year,
      fechaEntrega.month,
      fechaEntrega.day,
    );

    final diasRestantes = entrega.difference(hoySinHora).inDays;

    if (diasRestantes <= 0) {
      // Hoy o ya pasó
      return Colors.red;
    } else if (diasRestantes <= 7) {
      // Dentro de una semana
      return Colors.orange;
      // o Colors.amber si prefieres amarillo
    } else {
      // Más de una semana
      return Colors.green;
    }
  }

  Widget buildProyectoCard(Proyecto proyecto, int totalActivos, int index) {
    final puedeEditar = usuario?.rol == 0;
    final puedeArrastrar = puedeEditar && proyecto.status; // solo activos se reordenan

    final cuerpo = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (proyecto.status)
          Container(
            width: 8,
            color: _colorParaOrden(proyecto.orden, totalActivos),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${proyecto.clave} - ${proyecto.nombre}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    proyecto.fechaEntrega != null
                        ? formatearFecha(proyecto.fechaEntrega!)
                        : 'Sin fecha',
                    style: TextStyle(
                      fontSize: 16,
                      color: _colorFechaEntrega(proyecto.fechaEntrega),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // Zona arrastrable: la tarjeta completa MENOS el badge de orden
    final zonaArrastrable = puedeArrastrar
        ? ReorderableDelayedDragStartListener(index: index, child: cuerpo)
        : cuerpo;

    final badge = puedeEditar
        ? GestureDetector(
      onTap: () => _mostrarDialogoEdicion(proyecto),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5285A6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Icon(
          Icons.edit_note_rounded,
          color: Colors.white,
          size: 20, // El tamaño en Icon se define con 'size' en lugar de 'fontSize'
      ),

    ),
    )
        : const SizedBox.shrink();

    return KeyedSubtree(
      key: ValueKey(proyecto.clave),
      child: Opacity(
        opacity: proyecto.status ? 1.0 : 0.4,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: zonaArrastrable),
                if (puedeEditar)
                  Align(alignment: Alignment.center, child: badge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = <Widget>[];

    _agregarGrupo(menu, [
      ListTile(
        leading: const Icon(Icons.task),
        title: const Text('Proyectos'),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.receipt_long),
        title: const Text('Crear Vale'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ValesPage(
                viewModel: widget.valeViewModel,
                historialValesViewModel: widget.historialValesViewModel,
              ),
            ),
          );
        },
      ),
//      ListTile(
//        leading: const Icon(Icons.history),
//        title: const Text('Historial de Vales'),
//        onTap: () {
//          Navigator.pop(context);
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (_) => HistorialValesPage(
//                viewModel: widget.historialValesViewModel,
//              ),
//            ),
//          );
//        },
//      ),
    ]);

    _agregarGrupo(menu, [
      if (usuario != null &&
          (usuario!.rol == Roles.administrador ||
              usuario!.rol == Roles.supervisor))
        ListTile(
          leading: const Icon(Icons.fact_check),
          title: const Text('Aprobación de Vales'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AprobacionValesPage(
                  viewModel: widget.aprobacionValesViewModel,
                ),
              ),
            );
          },
        ),

      if (usuario != null &&
          (usuario!.rol == Roles.administrador ||
              usuario!.rol == Roles.almacen))
        ListTile(
          leading: const Icon(Icons.inventory),
          title: const Text('Entrega de Vales'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiberacionValesPage(
                  viewModel: widget.liberacionValesViewModel,
                ),
              ),
            );
          },
        ),

      if (usuario != null &&
          (usuario!.rol == Roles.administrador ||
              usuario!.rol == Roles.almacen))
        ListTile(
          leading: const Icon(Icons.build),
          title: const Text('Herramientas prestadas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HerramientasPage(
                  viewModel: widget.herramientasViewModel,
                ),
              ),
            );
          },
        ),
    ]);

    _agregarGrupo(menu, [
      if (usuario != null )
        ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: const Text('Seguimiento de Compras'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeguimientoComprasPage(
                  viewModel: SeguimientoComprasViewModel(
                    compraRepository: widget.compraRepository,
                    authService: widget.authService,
                    compraSolicitudSyncService:
                    widget.compraSolicitudSyncService,
                    compraSyncService: widget.compraSyncService,
                    usuarioRepository: widget.usuarioRepository,
                  ), viewModelCompras: widget.historialComprasViewModel,
                ),
              ),
            );
          },
        ),

      if (usuario != null &&
          (usuario!.rol == Roles.compras ||
              usuario!.rol == Roles.administrador))
        ListTile(
          leading: const Icon(Icons.add_shopping_cart),
          title: const Text('Crear Compra'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ComprasPage(
                  viewModel: widget.compraViewModel,
                  usuarioId: '',
                ),
              ),
            );
          },
        ),

//      if (usuario != null)
//        ListTile(
//          leading: const Icon(Icons.manage_history),
//          title: const Text('Historial de compras'),
//          onTap: () {
//            Navigator.pop(context);
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (_) => HistorialComprasPage(
//                  viewModel: HistorialComprasViewModel(
//                    compraService: widget.compraService,
//                    compraSyncService: widget.compraSyncService,
//                    usuarioRepository: widget.usuarioRepository,
//                  ),
//                ),
//              ),
//            );
//          },
//        ),
    ]);

    _agregarGrupo(menu, [
      if (usuario != null &&
          usuario!.rol == Roles.administrador)
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Administrar base de datos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDbPage(
                  viewModel: widget.adminDbViewModel,
                ),
              ),
            );
          },
        ),
    ]);

      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Cerrar sesión'),
        onTap: cerrarSesion,
      );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_ext.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 56,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usuario?.nombre ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(usuario?.descripcion ?? ''),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: menu,
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red, // Ícono rojo
                ),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red), // Texto rojo
                ),
                onTap: cerrarSesion,
              )

            ],
          ),
        ),
      ),


      floatingActionButton: esAdmin
          ? FloatingActionButton(
        onPressed: _mostrarDialogoNuevoProyecto,
        backgroundColor: const Color(0xFF4B4E6C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              'Lista de proyectos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedBuilder(
              animation: widget.homeViewModel,
              builder: (context, _) {
                return Expanded(
                  child: Column(
                    children: [
                      if (esAdmin || esSupervisor)
                        SwitchListTile(
                          title: const Text(
                            'Mostrar todos los proyectos',
                          ),
                          value: widget.homeViewModel.mostrarTodos,
                          onChanged:
                          widget.homeViewModel.cambiarMostrarTodos,
                        ),
                      Expanded(
                        child: cargandoProyectos
                            ? const Center(
                          child:
                          CircularProgressIndicator(),
                        )
                            : projetosVacios(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget projetosVacios() {
    final proyectosOrdenados = [...proyectos]..sort((a, b) {
      if (a.status != b.status) return a.status ? -1 : 1;
      if (!a.status) return 0;
      return a.orden.compareTo(b.orden);
    });

    final proyectosMostrar = widget.homeViewModel.mostrarTodos
        ? proyectosOrdenados
        : proyectosOrdenados
        .where((p) => p.status && p.tipo == 1)
        .toList();

    final totalActivos = proyectos.where((p) => p.status).length;

    return RefreshIndicator(
      onRefresh: () async {
        await widget.proyectoRepository.sincronizarFirebase();
        await cargarProyectos();
      },
      child: proyectosMostrar.isEmpty
          ? const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text('No hay proyectos disponibles'),
          ),
        ),
      )
          : ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        buildDefaultDragHandles: false, // el arrastre se activa desde la tarjeta, no un ícono
        itemCount: proyectosMostrar.length,
        itemBuilder: (context, index) {
          return buildProyectoCard(proyectosMostrar[index], totalActivos, index);
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;

          final proyectoMovido = proyectosMostrar[oldIndex];
          if (!proyectoMovido.status) return;

          final maxIndex = totalActivos - 1;
          if (newIndex > maxIndex) newIndex = maxIndex;
          if (newIndex == oldIndex) return;

          final nuevoOrden = newIndex + 1;

          // 1) Reordenar localmente y actualizar UI YA (optimista)
          final activos = proyectos.where((p) => p.status).toList()
            ..sort((a, b) => a.orden.compareTo(b.orden));
          activos.removeWhere((p) => p.clave == proyectoMovido.clave);

          final insertIndex = (nuevoOrden - 1).clamp(0, activos.length);
          activos.insert(insertIndex, proyectoMovido);

          final reordenadosLocal = <Proyecto>[
            for (int i = 0; i < activos.length; i++)
              Proyecto(
                clave: activos[i].clave,
                nombre: activos[i].nombre,
                fechaEntrega: activos[i].fechaEntrega,
                orden: i + 1,
                status: true,
                tipo: activos[i].tipo,
              ),
          ];

          setState(() {
            for (final actualizado in reordenadosLocal) {
              final i = proyectos.indexWhere((p) => p.clave == actualizado.clave);
              if (i != -1) proyectos[i] = actualizado;
            }
            _reordenarLista();
          });

          // 2) Sincronizar con Firebase/SQLite en segundo plano, sin bloquear la UI
          widget.homeViewModel.cambiarOrden(proyectoMovido, nuevoOrden, proyectos)
              .catchError((e) {
            debugPrint('Error sincronizando orden: $e');
            // Opcional: mostrar un snackbar o revertir si falla
          });
        },
      ),
    );
  }
}