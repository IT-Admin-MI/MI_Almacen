import 'package:flutter/material.dart';
import 'package:mi_almacen/services/firebase_service_impl.dart';
import 'package:mi_almacen/view/vales/historial_vales_page.dart';
import 'package:mi_almacen/view/vales/vales_page.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/vale_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';

import '../../models/Proyecto.dart';
import '../../models/Usuario.dart';
import '../vales/vales_aprobacion_page.dart';
import '../../repositories/proyecto_repository.dart';

import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {

  final AuthService authService;

  final ProyectoRepository proyectoRepository;

  final ValeViewModel valeViewModel;

  final AprobacionValesViewModel aprobacionValesViewModel;

  final HomeViewModel homeViewModel;

  final HistorialValesViewModel historialValesViewModel;

  const HomePage({
    super.key,
    required this.authService,
    required this.proyectoRepository,
    required this.valeViewModel,
    required  this.aprobacionValesViewModel,
    required this.homeViewModel,
    required this.historialValesViewModel,
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

  Future<void> _mostrarDialogoEdicion(Proyecto proyecto) async {
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

                    // ORDEN
                    TextFormField(
                      controller: ordenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Orden (prioridad)',
                        border: const OutlineInputBorder(),
                        errorText: errorOrden,
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

                    // ADVERTENCIA DESACTIVAR
                    if (!status && proyecto.status)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'El proyecto se marcará como inactivo y dejará de aparecer en la lista principal.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
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
                    final actualizado = Proyecto(
                      clave: proyecto.clave,
                      nombre: nombreCtrl.text.trim(),
                      orden: proyecto.orden, // se mantiene, orden solo cambia al activar/desactivar
                      status: status,
                      fechaEntrega: fechaEntrega,
                    );

                    if (status == false && proyecto.status == true) {
                      // Desactivando: orden → -1 y recompactar activos
                      await widget.homeViewModel.desactivarProyecto(proyecto, proyectos);
                      setState(() {
                        final i = proyectos.indexWhere((p) => p.clave == proyecto.clave);
                        if (i != -1) proyectos[i] = Proyecto(
                          clave: proyecto.clave,
                          nombre: nombreCtrl.text.trim(),
                          fechaEntrega: fechaEntrega,
                          orden: -1,
                          status: false,
                        );
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
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDialogoCambiarOrden(Proyecto proyecto) async {
    final ctrl = TextEditingController(text: proyecto.orden.toString());
    String? errorOrden;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Orden: ${proyecto.clave}'),
              content: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nuevo orden',
                  border: const OutlineInputBorder(),
                  helperText: 'Valor más bajo = mayor prioridad',
                  errorText: errorOrden,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoOrden = int.tryParse(ctrl.text.trim());

                    if (nuevoOrden == null) {
                      setDialogState(() => errorOrden = 'Ingresa un número válido');
                      return;
                    }

                    if (!widget.homeViewModel.ordenDisponible(
                        proyectos, nuevoOrden, proyecto.clave)) {
                      setDialogState(() => errorOrden = 'Este orden ya está en uso');
                      return;
                    }

                    final actualizado = Proyecto(
                      clave: proyecto.clave,
                      nombre: proyecto.nombre,
                      orden: nuevoOrden,
                      status: proyecto.status,
                      fechaEntrega: proyecto.fechaEntrega,
                    );

                    await widget.homeViewModel.actualizarProyecto(actualizado);

                    setState(() {
                      final i = proyectos.indexWhere((p) => p.clave == proyecto.clave);
                      if (i != -1) proyectos[i] = actualizado;
                      // Reordenar la lista local inmediatamente
                      proyectos.sort((a, b) {
                        if (a.status != b.status) return a.status ? -1 : 1;
                        return a.orden.compareTo(b.orden);
                      });
                    });

                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
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

  Widget buildProyectoCard(Proyecto proyecto) {
    final puedeEditar = usuario?.rol == 0 || usuario?.rol == 1;

    return Opacity(
      opacity: proyecto.status ? 1.0 : 0.4,
      child: GestureDetector(
        onLongPress: puedeEditar ? () => _mostrarDialogoEdicion(proyecto) : null,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${proyecto.clave} - ${proyecto.nombre}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proyecto.fechaEntrega != null
                            ? formatearFecha(proyecto.fechaEntrega!)
                            : 'Sin fecha',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (puedeEditar) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onLongPress: () => _mostrarDialogoCambiarOrden(proyecto),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_indicator, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${proyecto.orden}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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
        child: SafeArea(  // ← Respeta la zona segura del sistema
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.asset(
                        'assets/images/logo_bn.png',
                        width: 56,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usuario?.nombre ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario?.descripcion ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [

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
                            builder: (_) => ValesPage(viewModel: widget.valeViewModel),
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Historial de Vales'),
                      onTap: () {

                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistorialValesPage(
                              viewModel: widget.historialValesViewModel,
                            ),
                          ),
                        );

                      },
                    ),

                    if (usuario != null && (usuario!.rol == 0 || usuario!.rol == 1))
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

                    // ← Cerrar sesión al final del ListView, no fuera de él
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      onTap: cerrarSesion,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Lista de proyectos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (usuario?.rol == 0 || usuario?.rol == 1)
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
                  onPressed: () => _mostrarDialogoNuevoProyecto(),
                ),
            ],
          ),
          // ← Todo dentro del AnimatedBuilder
          AnimatedBuilder(
            animation: widget.homeViewModel,
            builder: (context, _) {
              return Expanded(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        widget.homeViewModel.mostrarTodos
                            ? 'Mostrar todos los proyectos'
                            : 'Mostrar todos los proyectos',
                      ),
                      value: widget.homeViewModel.mostrarTodos,
                      onChanged: widget.homeViewModel.cambiarMostrarTodos,
                    ),
                    Expanded(
                      child: cargandoProyectos
                          ? const Center(child: CircularProgressIndicator())
                          : projetosVacios(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget projetosVacios() {
    final proyectosOrdenados = [...proyectos]..sort((a, b) {
      if (a.status != b.status) return a.status ? -1 : 1;
      if (!a.status) return 0;
      return a.orden.compareTo(b.orden); // ← int.compareTo, no toString
    });

    final proyectosMostrar = widget.homeViewModel.mostrarTodos
        ? proyectosOrdenados
        : proyectosOrdenados.where((p) => p.status).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await widget.proyectoRepository.sincronizarFirebase();
        await cargarProyectos();
      },
      child: proyectosMostrar.isEmpty
          ? const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(), // ← necesario para que funcione el gesto aunque esté vacío
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text('No hay proyectos disponibles'),
          ),
        ),
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // ← necesario para que el gesto siempre funcione
        itemCount: proyectosMostrar.length,
        itemBuilder: (context, index) {
          return buildProyectoCard(proyectosMostrar[index]);
        },
      ),
    );
  }
}