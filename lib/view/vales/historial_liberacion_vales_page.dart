import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/viewmodels/historial_liberacion_vales_viewmodel.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

class HistorialLiberacionesPage extends StatefulWidget {
  final HistorialLiberacionesViewModel viewModel;

  const HistorialLiberacionesPage({super.key, required this.viewModel});

  @override
  State<HistorialLiberacionesPage> createState() =>
      _HistorialLiberacionesPageState();
}

class _HistorialLiberacionesPageState
    extends State<HistorialLiberacionesPage> {

  bool _refrescando = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.cargarHistorial();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _exportar() async {
    try {
      final bytes = await widget.viewModel.exportarExcel();
      if (!mounted) return;

      final nombreArchivo =
          'vales_entregados_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (Platform.isWindows) {
        const typeGroup = XTypeGroup(
          label: 'Excel',
          extensions: ['xlsx'],
        );

        final location = await getSaveLocation(
          suggestedName: nombreArchivo,
          acceptedTypeGroups: [typeGroup],
        );

        if (location == null) return;

        final file = File(location.path);
        await file.writeAsBytes(bytes, flush: true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en ${location.path}'),
          ),
        );

      } else {
        // Android: no hay "guardar como" nativo comparable, se comparte
        final directorio = await getApplicationDocumentsDirectory();
        final file = File('${directorio.path}/$nombreArchivo');
        await file.writeAsBytes(bytes, flush: true);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Historial de vales entregados',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {

        final vales = widget.viewModel.vales;
        final proyectos = widget.viewModel.proyectos;
        final proyectoSeleccionado = widget.viewModel.proyectoSeleccionado;

        return Scaffold(
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
                icon: widget.viewModel.exportando
                    ? const SizedBox(
                  width: 26, height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.sim_card_download_outlined),
                tooltip: 'Exportar a Excel',
                onPressed: widget.viewModel.exportando ? null : _exportar,
              ),
            ],
          ),
          body: widget.viewModel.cargando && !_refrescando
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() => _refrescando = true);
                await widget.viewModel.actualizar();
                setState(() => _refrescando = false);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: const Center(
                      child: Text(
                        'Historial de vales',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // FILTRO FECHAS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                widget.viewModel.fechaInicio == null
                                    ? 'Desde'
                                    : '${widget.viewModel.fechaInicio!.day}/${widget.viewModel.fechaInicio!.month}/${widget.viewModel.fechaInicio!.year}',
                              ),
                              onPressed: () => _seleccionarFecha(desde: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                widget.viewModel.fechaFin == null
                                    ? 'Hasta'
                                    : '${widget.viewModel.fechaFin!.day}/${widget.viewModel.fechaFin!.month}/${widget.viewModel.fechaFin!.year}',
                              ),
                              onPressed: () => _seleccionarFecha(desde: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

// LIMPIAR FILTROS
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
                  vales.isEmpty
                      ? const SliverFillRemaining(
                    child: Center(
                      child: Text('No hay vales entregados',
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ),
                  )
                      : SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildValeCard(vales[index]),
                      childCount: vales.length,
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

  Widget _buildValeCard(Vale vale) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('Vale ${vale.id}'),
        subtitle: Text(
          '${vale.usuarioNombre}\n'
              'Entregado: ${vale.fechaValidacion != null ? "${vale.fechaValidacion!.day}/${vale.fechaValidacion!.month}/${vale.fechaValidacion!.year}" : "-"}',
        ),
        children: vale.items.map((item) => ListTile(
          title: Text(item.material.descripcion),
          subtitle: Text('${item.cantidad} ${item.unidad} · ${item.proyecto?.clave ?? "-"}'),
        )).toList(),
      ),
    );
  }
  Future<void> _seleccionarFecha({required bool desde}) async {

    final fecha = await showDatePicker(
      context: context,
      initialDate: desde
          ? (widget.viewModel.fechaInicio ?? DateTime.now())
          : (widget.viewModel.fechaFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    if (desde) {
      widget.viewModel.seleccionarFechaInicio(fecha);
    } else {
      widget.viewModel.seleccionarFechaFin(fecha);
    }
  }
}

