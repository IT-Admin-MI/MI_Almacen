import 'package:flutter/material.dart';
import 'package:mi_almacen/viewmodels/seguimiento_compras_viewmodel.dart';
import 'package:mi_almacen/widgets/compra_timeline_card.dart';
import 'package:mi_almacen/widgets/status_overlay.dart';

class SeguimientoComprasPage extends StatefulWidget {
  final SeguimientoComprasViewModel viewModel;

  const SeguimientoComprasPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<SeguimientoComprasPage> createState() =>
      _SeguimientoComprasPageState();
}

class _SeguimientoComprasPageState extends State<SeguimientoComprasPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.cargar();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seguimiento de Compras'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Estado de compras"),
              Tab(text: "Solicitudes"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarDialogoSolicitud,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _estadoCompras(),
            _solicitudes(),
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
            onToggle: () => vm.toggleExpandido(compra.id!),
            onAvanzar: () => vm.avanzarEstado(compra),
          );
        },
      ),
    );
  }

  /// Envuelve el contenido con un gesto de swipe (en el primer elemento
  /// invisible arriba) para disparar la sincronización manual con Firebase.
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
                    await widget.viewModel.crearSolicitud(
                      descripcion: descripcionController.text,
                      requiereRevision: requiereRevision,
                    );
                    if (mounted) Navigator.pop(context);
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