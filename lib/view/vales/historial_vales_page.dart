import 'package:flutter/material.dart';

import '../../models/Vale.dart';
import '../../viewmodels/historial_vales_viewmodel.dart';

class HistorialValesPage extends StatefulWidget {
  final HistorialValesViewModel viewModel;

  const HistorialValesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<HistorialValesPage> createState() =>
      _HistorialValesPageState();
}

class _HistorialValesPageState
    extends State<HistorialValesPage> {

  @override
  void initState() {
    super.initState();
    widget.viewModel.cargarVales();
  }

  Future<void> _seleccionarFecha({
    required bool desde,
  }) async {

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

        final vales = widget.viewModel.vales;
        print("Vales en pantalla: ${vales.length}");
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
            onRefresh: widget.viewModel.actualizar,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
            SliverToBoxAdapter(
                child: const Center(
                  child: Text(
                    'Historial de vales',
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
                      value: widget.viewModel.proyectos.contains(widget.viewModel.proyectoSeleccionado)
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
                        onPressed: () {
                          widget.viewModel.seleccionarProyecto(null);
                          widget.viewModel.seleccionarFechaDesde(null);
                          widget.viewModel.seleccionarFechaHasta(null);
                        },
                      ),
                    ),
                  ),
                ),

                widget.viewModel.vales.isEmpty
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
                          'No existen vales',
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
                      final Vale vale = widget.viewModel.vales[index];
                      return Opacity(
                        opacity: vale.estado == 0 ? 1.0 : 0.5,
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ExpansionTile(
                            title: Text(vale.id),
                            subtitle: Text(
                              '${vale.usuarioNombre}\n${vale.departamento}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estado: ${vale.estado == 1 ? "Aprobado" : vale.estado == 2 ? "Rechazado" : "No aprobado"}',
                                    ),
                                    Text('Fecha: ${vale.fechaCreacion}'),
                                    const Divider(),
                                    ...vale.items.map(
                                          (item) => ListTile(
                                        dense: true,
                                        title: Text(item.material.descripcion),
                                        subtitle: Text('${item.cantidad} ${item.unidad}'),
                                        trailing: Text(item.proyecto?.clave ?? ''),
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
                    childCount: widget.viewModel.vales.length,
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