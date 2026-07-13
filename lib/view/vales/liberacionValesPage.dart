import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/services/excel_service_impl.dart';
import 'package:mi_almacen/view/vales/historial_liberacion_vales_page.dart';
import 'package:mi_almacen/viewmodels/LiberacionValesViewModel.dart';
import 'package:mi_almacen/viewmodels/historial_liberacion_vales_viewmodel.dart';
import 'package:mi_almacen/widgets/status_overlay.dart';

class LiberacionValesPage extends StatefulWidget {
  final LiberacionValesViewModel viewModel;

  const LiberacionValesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<LiberacionValesPage> createState() =>
      _LiberacionValesPageState();
}

class _LiberacionValesPageState
    extends State<LiberacionValesPage> {

  bool _refrescando = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.cargarVales();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
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
            title: Image.asset('assets/images/logo_ext.png', height: 40, fit: BoxFit.contain),
            actions: [
              IconButton(
                iconSize: 34.0,
                icon: const Icon(Icons.history),
                tooltip: 'Historial de liberados',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistorialLiberacionesPage(
                        viewModel: HistorialLiberacionesViewModel(
                          valeRepository: widget.viewModel.valeRepository,
                          proyectoRepository: widget.viewModel.proyectoRepository,
                          excelExportService: ExcelServiceImpl(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          body: widget.viewModel.cargando && !_refrescando
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() => _refrescando = true);

                final controller = StatusOverlay.mostrarCargando(
                  context,
                  mensaje: 'Actualizando...',
                );

                try {
                  await widget.viewModel.actualizar();

                  if (!mounted) return;

                  controller.completar(
                    exito: true,
                    mensaje: 'Vales actualizados correctamente',
                  );
                } catch (_) {
                  if (!mounted) return;

                  controller.completar(
                    exito: false,
                    mensaje: 'Error al actualizar los vales',
                  );
                } finally {
                  if (mounted) {
                    setState(() => _refrescando = false);
                  }
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: const Center(
                      child: Text(
                        'Entrega de vales',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // FILTRO PROYECTO
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<Proyecto?>(
                        value: proyectos
                            .where((p) => p.clave == proyectoSeleccionado?.clave)
                            .firstOrNull,
                        decoration: const InputDecoration(
                          labelText: 'Proyecto',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<Proyecto?>(
                            value: null,
                            child: Text("Todos"),
                          ),
                          ...proyectos.map(
                                (p) => DropdownMenuItem<Proyecto?>(
                              value: p,
                              child: Text('${p.clave}'),
                            ),
                          ),
                        ],
                        onChanged: widget.viewModel.seleccionarProyecto,
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
                      ? SliverFillRemaining(
                    child: _buildEmpty(),
                  )
                      : SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final vale = vales[index];
                        return _buildValeCard(vale);
                      },
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

  Future<void> _seleccionarFecha({
    required bool desde,
  }) async {

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

  Widget _buildEmpty() {

    return Center(

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Opacity(

            opacity: .15,

            child: Image.asset(
              'assets/images/logo_bn.png',
              width: 180,
            ),

          ),

          const SizedBox(height: 20),

          const Text(
            "No hay vales pendientes de entregar",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          )

        ],
      ),
    );
  }

  Widget _buildValeCard(Vale vale) {

    return Card(

      margin: const EdgeInsets.all(8),

      child: ExpansionTile(

        title: Text("Vale ${vale.id}"),

        subtitle: Text(
          "${vale.usuarioNombre}\n${vale.fechaCreacion.day}/${vale.fechaCreacion.month}/${vale.fechaCreacion.year}",
        ),

        children: [

          const Divider(),

          Padding(

            padding: const EdgeInsets.all(12),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(

                  "Materiales",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),

                ),

                const SizedBox(height: 10),

                ...vale.items.map(

                      (item) {

                    return Card(

                      child: ListTile(

                        title: Text(
                          item.material.descripcion,
                        ),

                        subtitle: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                                "Código: ${item.material.codigo}"),

                            Text(
                                "Cantidad: ${item.cantidad} ${item.unidad}"),

                            Text(
                                "Proyecto: ${item.proyecto?.clave ?? '-'}"),

                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(

                        icon: const Icon(Icons.check),

                        label: const Text(
                            " Entregar"),

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),

                        onPressed: () =>
                            _confirmarLiberacion(vale),

                      ),
                    ),


                    const SizedBox(width: 10),


                    Expanded(
                      child: ElevatedButton.icon(

                        icon: const Icon(Icons.close),

                        label:
                        const Text("Rechazar"),

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),

                        onPressed: () =>
                            _confirmarRechazo(vale),

                      ),
                    ),

                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _confirmarLiberacion(
      Vale vale) async {

    final confirmar = await showDialog<bool>(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
          const Text("Entregar Vale"),

          content: Text(
              "¿Desea entregar el vale ${vale.id}?"),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context, false);

              },

              child:
              const Text("Cancelar"),

            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(
                    context, true);

              },

              child:
              const Text("Entregar"),

            )

          ],
        );
      },
    );

    if(confirmar == true){
      final controller = StatusOverlay.mostrarCargando(
        context,
        mensaje: 'Entregando vale...',
      );

      final ok = await widget.viewModel.actualizarLiberacionVale(
        valeId: vale.id,
        liberado: 1,
      );

      if (!mounted) return;

      controller.completar(
        exito: ok,
        mensaje: ok
            ? 'Vale entregado correctamente'
            : 'Error al entregar el vale',
      );
    }
  }

  Future<void> _confirmarRechazo(
      Vale vale) async {


    final comentarioController =
    TextEditingController();


    final confirmar =
    await showDialog<bool>(

        context: context,

        builder: (_) {

          return AlertDialog(

            title:
            const Text(
                "Rechazar Vale"),

            content:
            TextField(

              controller:
              comentarioController,

              maxLines: 3,

              decoration:
              const InputDecoration(

                labelText:
                "Motivo del rechazo",

                border:
                OutlineInputBorder(),

              ),

            ),


            actions: [

              TextButton(

                onPressed: (){
                  Navigator.pop(
                      context,false);
                },

                child:
                const Text(
                    "Cancelar"),

              ),


              ElevatedButton(

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.red,
                  foregroundColor:
                  Colors.white,
                ),

                onPressed: (){

                  Navigator.pop(
                      context,true);

                },

                child:
                const Text(
                    "Rechazar"),

              )

            ],

          );

        }

    );


    if(confirmar == true){
      final controller = StatusOverlay.mostrarCargando(
        context,
        mensaje: 'Rechazando vale...',
      );

      final ok = await widget.viewModel.actualizarLiberacionVale(
        valeId: vale.id,
        liberado: -1,
        comentario: comentarioController.text,
      );

      if (!mounted) return;

      controller.completar(
        exito: ok,
        mensaje: ok
            ? 'Vale rechazado correctamente'
            : 'Error al rechazar el vale',
      );
    }

  }
}