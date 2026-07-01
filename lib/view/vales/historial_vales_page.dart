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
            title: const Text('Historial de Vales'),
          ),

          body: widget.viewModel.cargando
              ? const Center(
            child: CircularProgressIndicator(),
          ): RefreshIndicator(
              onRefresh: widget.viewModel.actualizar,
              child: Column(
            children: [

              Padding(
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
              Padding(
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

              Expanded(
                child: vales.isEmpty
                    ? const Center(

                  child: Text('No existen vales'),
                widget.viewModel.vales.isEmpty
                    ? const SliverFillRemaining(
                  child: Center(child: Text('No existen vales')),
                )
                    : ListView.builder(
                  itemCount: vales.length,
                  itemBuilder: (context, index) {

                    final Vale vale = vales[index];

                    return Opacity(
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  'Estado: ${vale.estado == 1 ? "Aprobado" : "No aprobado"}',
                                ),


                                Text(
                                  'Fecha: ${vale.fechaCreacion}',
                                ),

                                const Divider(),

                                ...vale.items.map(
                                      (item) => ListTile(
                                    dense: true,
                                    title: Text(
                                      item.material.descripcion,
                                    ),
                                    subtitle: Text(
                                      '${item.cantidad} ${item.unidad}',
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
                                      'Estado: ${vale.estado == 1 ? "Aprobado" : "No aprobado"}',
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
        );
      },
    );
  }
}