import 'package:flutter/material.dart';
import 'package:mi_almacen/constants/estado_compra_labels.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/viewmodels/historial_compras_viewmodel.dart';
import 'package:mi_almacen/widgets/status_overlay.dart';

class HistorialComprasPage extends StatefulWidget {
  final HistorialComprasViewModel viewModel;

  const HistorialComprasPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<HistorialComprasPage> createState() => _HistorialComprasPageState();
}

class _HistorialComprasPageState extends State<HistorialComprasPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.cargarCompras();
  }

  Future<void> _seleccionarFecha({required bool desde}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: desde
          ? (widget.viewModel.fechaDesde ?? DateTime.now())
          : (widget.viewModel.fechaHasta ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    if (desde) {
      widget.viewModel.seleccionarFechaDesde(fecha);
    } else {
      widget.viewModel.seleccionarFechaHasta(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo_ext.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          body: widget.viewModel.cargando
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final controller = StatusOverlay.mostrarCargando(
                  context,
                  mensaje: 'Actualizando historial...',
                );

                try {
                  await widget.viewModel.actualizar();

                  if (!mounted) return;

                  controller.completar(
                    exito: true,
                    mensaje: 'Historial actualizado correctamente',
                  );
                } catch (e) {
                  if (!mounted) return;

                  controller.completar(
                    exito: false,
                    mensaje: 'Error al actualizar el historial',
                  );
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Historial de compras',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String?>(
                        value: widget.viewModel.proyectos
                            .contains(widget.viewModel.proyectoSeleccionado)
                            ? widget.viewModel.proyectoSeleccionado
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Proyecto',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("Todos"),
                          ),
                          ...widget.viewModel.proyectos.map(
                                (p) => DropdownMenuItem<String?>(
                              value: p,
                              child: Text(p),
                            ),
                          ),
                        ],
                        onChanged: widget.viewModel.seleccionarProyecto,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                widget.viewModel.fechaDesde == null
                                    ? 'Desde'
                                    : '${widget.viewModel.fechaDesde!.day}/${widget.viewModel.fechaDesde!.month}/${widget.viewModel.fechaDesde!.year}',
                              ),
                              onPressed: () => _seleccionarFecha(desde: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                widget.viewModel.fechaHasta == null
                                    ? 'Hasta'
                                    : '${widget.viewModel.fechaHasta!.day}/${widget.viewModel.fechaHasta!.month}/${widget.viewModel.fechaHasta!.year}',
                              ),
                              onPressed: () => _seleccionarFecha(desde: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar filtros'),
                          onPressed: widget.viewModel.limpiarFiltros,
                        ),
                      ),
                    ),
                  ),

                  widget.viewModel.compras.isEmpty
                      ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_bn.png',
                            width: 150,
                            color: Colors.grey.withOpacity(0.4),
                            colorBlendMode: BlendMode.modulate,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No existen compras',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final Compra compra = widget.viewModel.compras[index];

                        return Opacity(
                          opacity: compra.liberada ? 0.5 : 1.0,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ExpansionTile(
                              title: Text(compra.nombre),
                              subtitle: Text(
                                '${widget.viewModel.nombreComprador(compra.compradorId)}\n'
                                    'OC: ${compra.ordenCompra}',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estado: ${estadoCompraLabels[compra.estado] ?? compra.estado.name}',
                                      ),
                                      Text('Tipo: ${compra.tipoCompra.name}'),
                                      Text('Fecha: ${compra.fechaSolicitud}'),
                                      if (compra.fechaLiberacion != null)
                                        Text('Liberada: ${compra.fechaLiberacion}'),
                                      if (compra.comentario != null &&
                                          compra.comentario!.isNotEmpty)
                                        Text('Comentario: ${compra.comentario}'),
                                      const Divider(),
                                      ...compra.items.map(
                                            (item) => ListTile(
                                          dense: true,
                                          title: Text(item.nombre),
                                          subtitle: Text(
                                            '${item.cantidad} ${item.unidad}',
                                          ),
                                          trailing: Text(item.proyectoClave ?? ''),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: widget.viewModel.compras.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}