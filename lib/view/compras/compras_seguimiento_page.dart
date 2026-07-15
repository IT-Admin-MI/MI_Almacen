import 'package:flutter/material.dart';
import 'package:mi_almacen/viewmodels/seguimiento_compras_viewmodel.dart';

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

class _SeguimientoComprasPageState
    extends State<SeguimientoComprasPage> {

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

      length: 2,

      child: Scaffold(

        appBar: AppBar(

          title: const Text(
            'Seguimiento de Compras',
          ),

          bottom: const TabBar(

            tabs: [

              Tab(
                text: "Estado de compras",
              ),

              Tab(
                text: "Solicitudes",
              ),

            ],
          ),
        ),

        floatingActionButton:
        FloatingActionButton(
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

    if (widget.viewModel.cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.viewModel.compras.isEmpty) {
      return const Center(
        child: Text(
          "No hay compras vigentes",
        ),
      );
    }

    return ListView.builder(

      itemCount:
      widget.viewModel.compras.length,

      itemBuilder: (_, index) {

        final compra =
        widget.viewModel.compras[index];

        return ExpansionTile(

          title: Text(
            compra.nombre,
          ),

          subtitle: Text(
            compra.ordenCompra,
          ),

          children: const [

            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text("Aprobada"),
            ),

            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text(
                "Orden de compra creada",
              ),
            ),

            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text(
                "Orden autorizada",
              ),
            ),

            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text("Pagada"),
            ),

            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text(
                "Producto enviado",
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _solicitudes() {

    if (widget.viewModel.cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(

      itemCount:
      widget.viewModel.solicitudes.length,

      itemBuilder: (_, index) {

        final solicitud =
        widget.viewModel.solicitudes[index];

        return Card(

          margin: const EdgeInsets.all(8),

          child: ListTile(

            title: Text(
              solicitud.descripcion,
            ),

            subtitle: Text(
              solicitud.estado.name,
            ),

          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoSolicitud()
  async {

    final descripcionController =
    TextEditingController();

    bool requiereRevision = false;

    await showDialog(

      context: context,

      builder: (_) {

        return StatefulBuilder(

          builder: (_, setState) {

            return AlertDialog(

              title: const Text(
                "Nueva Solicitud",
              ),

              content: Column(

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  TextField(

                    controller:
                    descripcionController,

                    decoration:
                    const InputDecoration(

                      labelText:
                      "Descripción",

                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SwitchListTile(

                    title: const Text(
                      "Requiere revisión del solicitante",
                    ),

                    value:
                    requiereRevision,

                    onChanged: (v) {

                      setState(() {

                        requiereRevision =
                            v;

                      });

                    },

                  ),

                ],
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );

                  },

                  child: const Text(
                    "Cancelar",
                  ),

                ),

                FilledButton(

                  onPressed: () async {

                    await widget.viewModel
                        .crearSolicitud(

                      descripcion:
                      descripcionController
                          .text,

                      requiereRevision:
                      requiereRevision,

                    );

                    if (mounted) {
                      Navigator.pop(
                        context,
                      );
                    }

                  },

                  child: const Text(
                    "Crear",
                  ),

                ),

              ],
            );
          },
        );
      },
    );
  }
}