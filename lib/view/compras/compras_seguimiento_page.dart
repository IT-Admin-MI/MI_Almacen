import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/view/compras/historial_compras_page.dart';
import 'package:mi_almacen/viewmodels/historial_compras_viewmodel.dart';
import 'package:mi_almacen/viewmodels/seguimiento_compras_viewmodel.dart';
import 'package:mi_almacen/widgets/compra_timeline_card.dart';
import 'package:mi_almacen/widgets/status_overlay.dart';

class SeguimientoComprasPage extends StatefulWidget {
  final SeguimientoComprasViewModel viewModel;
  final HistorialComprasViewModel viewModelCompras;

  const SeguimientoComprasPage({
    super.key,
    required this.viewModel,
    required this.viewModelCompras,
  });

  @override
  State<SeguimientoComprasPage> createState() =>
      _SeguimientoComprasPageState();
}

class _SeguimientoComprasPageState extends State<SeguimientoComprasPage> {
  final Set<String> _procesando = {}; // NUEVO: ids de compras en progreso
  bool _inicializando = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    _inicializar();
  }

  Future<void> _inicializar() async {
    setState(() {
      _inicializando = true;
    });

    try {
      //await widget.viewModel.sincronizar();
      await widget.viewModel.cargar();
    } finally {
      if (mounted) {
        setState(() {
          _inicializando = false;
        });
      }
    }
  }
  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_inicializando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo_ext.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          actions: [
            IconButton(
              iconSize: 34.0,
              icon: const Icon(Icons.history),
              tooltip: 'Historial de liberados',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorialComprasPage(
                      viewModel: HistorialComprasViewModel(
                        compraService: widget.viewModelCompras.compraService,
                        compraSyncService: widget.viewModelCompras.compraSyncService,
                        usuarioRepository: widget.viewModelCompras.usuarioRepository,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarDialogoSolicitud,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Seguimiento de compras',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            const TabBar(
              tabs: [
                Tab(text: "Estado de compras"),
                Tab(text: "Solicitudes"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _estadoCompras(),
                  _solicitudes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoCompras() {
    final vm = widget.viewModel;

    // Solo mostramos el spinner de pantalla completa cuando de verdad
    // no hay nada que mostrar todavía (primera carga en frío).
    if (vm.cargando && vm.compras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.compras.isEmpty) {
      return _envolverConSync(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_bn.png',
                  width: 100,
                  color: Colors.grey.withOpacity(0.4),
                  colorBlendMode: BlendMode.modulate,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin compras',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _envolverConSync(
        ListView.builder(
          itemCount: vm.compras.length,
          itemBuilder: (_, index) {
            final compra = vm.compras[index];

            return CompraTimelineCard(
              key: ValueKey(compra.id),
              compra: compra,
              expandido: vm.estaExpandido(compra.id!),
              esUsuarioCompras: vm.esUsuarioCompras,
              esSolicitante: vm.esSolicitanteDe(compra),
              pendienteAprobacion: vm.requiereAprobacionPendiente(compra),
              procesando: _procesando.contains(compra.id),
              onToggle: () => vm.toggleExpandido(compra.id!),
              onAvanzar: () => _avanzar(compra),
              onAprobarRevision: () => _aprobarRevision(compra),
            );
          },
        ),
    );
  }

  Future<void> _avanzar(Compra compra) async {
    setState(() => _procesando.add(compra.id!));

    final overlay = StatusOverlay.mostrarCargando(
      context,
      mensaje: 'Actualizando compra...',
    );

    final resultado = await widget.viewModel.avanzarEstado(compra);

    overlay.completar(
      exito: resultado.success,
      mensaje: resultado.success
          ? resultado.liberada
          ? 'Compra liberada correctamente'
          : 'Estado actualizado'
          : 'Error al actualizar compra',
      duracion: const Duration(seconds: 1),
    );

    if (mounted) {
      setState(() => _procesando.remove(compra.id!));
    }
  }

  Future<void> _aprobarRevision(Compra compra) async {
    setState(() => _procesando.add(compra.id!));

    final overlay = StatusOverlay.mostrarCargando(
      context,
      mensaje: 'Aprobando compra...',
    );

    final ok = await widget.viewModel.aprobarRevisionSolicitante(compra);

    overlay.completar(
      exito: ok,
      mensaje: ok
          ? 'Compra aprobada'
          : 'No se pudo aprobar la compra',
      duracion: const Duration(seconds: 2),
    );

    if (mounted) {
      setState(() => _procesando.remove(compra.id!));
    }
  }


  Widget _envolverConSync(Widget child) {
    final vm = widget.viewModel;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            final exito = await vm.sincronizar();

            if (mounted) {
              StatusOverlay.mostrar(
                context,
                exito: exito,
                mensaje: exito
                    ? 'Sincronización completada'
                    : 'Error al sincronizar',
                duracion: const Duration(seconds: 2),
              );
            }
          },
          child: child is ListView
              ? child
              : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: child,
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _solicitudes() {
    final vm = widget.viewModel;

    if (vm.cargando && vm.solicitudes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.solicitudes.isEmpty) {
      return _envolverConSync(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_bn.png',
                  width: 100,
                  color: Colors.grey.withOpacity(0.4),
                  colorBlendMode: BlendMode.modulate,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin solicitudes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _envolverConSync(
      ListView.builder(
        itemCount: vm.solicitudes.length,
        itemBuilder: (_, index) {
          final solicitud = vm.solicitudes[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(solicitud.descripcion),
              subtitle: Text(
                'Solicitante: ${vm.nombreSolicitante(solicitud.solicitanteId)}\n'
                    '${solicitud.estado.name}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarDialogoSolicitud() async {
    final descripcionController = TextEditingController();
    bool requiereRevision = false;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text("Nueva Solicitud"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Requiere revisión del solicitante"),
                    value: requiereRevision,
                    onChanged: (v) => setState(() => requiereRevision = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                FilledButton(
                  onPressed: () async {

                    final overlay = StatusOverlay.mostrarCargando(
                      context,
                      mensaje: 'Creando solicitud...',
                    );

                    final ok = await widget.viewModel.crearSolicitud(
                      descripcion: descripcionController.text,
                      requiereRevision: requiereRevision,
                    );

                    overlay.completar(
                      exito: ok,
                      mensaje: ok
                          ? 'Solicitud creada correctamente'
                          : 'Error al crear solicitud',
                      duracion: const Duration(seconds: 2),
                    );

                    if (ok && mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Crear"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}