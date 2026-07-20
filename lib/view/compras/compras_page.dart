import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/compra_solicitud.dart';
import 'package:mi_almacen/utils/id_generator.dart';
import 'package:mi_almacen/viewmodels/compra_viewmodel.dart';

class ComprasPage extends StatefulWidget {
  final CompraViewModel viewModel;
  final String usuarioId; // comprador logueado

  ComprasPage({
    super.key,
    required this.viewModel,
    required this.usuarioId,
  });

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
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
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_ext.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : vm.solicitudes.isEmpty
          ? Center(
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
              'Sin solicitudes pendientes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: vm.solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = vm.solicitudes[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              onTap: () => _abrirRevision(solicitud),
              title: Text(
                solicitud.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Solicitante: ${vm.nombreSolicitante(solicitud.solicitanteId)}\n'
                    '${solicitud.fechaSolicitud.day}/${solicitud.fechaSolicitud.month}/${solicitud.fechaSolicitud.year}'
                    '${solicitud.requiereRevisionSolicitante ? ' · Requiere revisión' : ''}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }



  Future<void> _abrirRevision(SolicitudCompra solicitud) async {
    widget.viewModel.limpiarItems();
    final _formKey = GlobalKey<FormState>();
    bool guardando = false;

    final ordenController = TextEditingController();
    TipoCompra tipoCompra = TipoCompra.proyecto;
    bool errorItems = false;
    bool intentoAprobar = false;


    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solicitud.descripcion,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: ordenController,
                          decoration: const InputDecoration(
                            labelText: 'Orden de compra',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Capture la orden de compra';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<TipoCompra>(
                          value: tipoCompra,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de compra',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TipoCompra.proyecto,
                              child: Text('Proyecto'),
                            ),
                            DropdownMenuItem(
                              value: TipoCompra.stock,
                              child: Text('Stock'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => tipoCompra = v);
                            }
                          },
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await _mostrarDialogoItem(
                                  solicitud: solicitud,
                                );
                                setModalState(() {});
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar item'),
                            ),
                          ],

                        ),


                        if (intentoAprobar && widget.viewModel.itemsEnConstruccion.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Debe agregar al menos un item.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        ...widget.viewModel.itemsEnConstruccion
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return ListTile(
                            dense: true,
                            title: Text(item.nombre),
                            subtitle: Text(
                              '${item.cantidad} ${item.unidad}'
                                  '${item.proyectoClave != null ? ' · Proy: ${item.proyectoClave}' : ''}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                widget.viewModel.eliminarItem(i);
                                setModalState(() {});
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: guardando
                                    ? null
                                    : () => _rechazar(
                                  solicitud,
                                  setGuardando: (v) => setModalState(() => guardando = v),
                                ),
                                child: const Text('Rechazar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.metint01,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: guardando
                                    ? null
                                    : () {
                                  setModalState(() {
                                    intentoAprobar = true;
                                  });

                                  if (!_formKey.currentState!.validate()) return;
                                  if (widget.viewModel.itemsEnConstruccion.isEmpty) return;

                                  _aprobar(
                                    solicitud: solicitud,
                                    ordenCompra: ordenController.text,
                                    tipoCompra: tipoCompra,
                                    setGuardando: (v) => setModalState(() => guardando = v),
                                  );
                                },
                                child: guardando
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : const Text('Aprobar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDialogoItem({
    required SolicitudCompra solicitud,
  }) async {
    final vm = widget.viewModel;

    String? materialClaveSeleccionada;
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    String unidadSeleccionada = 'pza';
    final observacionesController = TextEditingController();
    final numeroParteController = TextEditingController();
    String? proyectoClave;

    // NUEVO: mensajes de error para cada campo obligatorio
    String? errorNombre;
    String? errorCantidad;

    vm.limpiarBusquedaMaterial();

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo item'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Buscar material',
                        ),
                        onChanged: (texto) async {
                          await vm.buscarMaterial(texto);
                          setState(() {});
                        },
                      ),
                      if (vm.resultadosBusqueda.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: vm.resultadosBusqueda.length,
                            itemBuilder: (_, i) {
                              final material = vm.resultadosBusqueda[i];
                              return ListTile(
                                dense: true,
                                title: Text(material.descripcion),
                                subtitle: Text(material.codigo),
                                onTap: () {
                                  materialClaveSeleccionada = material.codigo;
                                  nombreController.text = material.descripcion;
                                  vm.limpiarBusquedaMaterial();
                                  setState(() {
                                    errorNombre = null;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre / descripción',
                          errorText: errorNombre,
                        ),
                        onChanged: (_) {
                          if (errorNombre != null) {
                            setState(() => errorNombre = null);
                          }
                        },
                      ),
                      TextField(
                        controller: cantidadController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          errorText: errorCantidad,
                        ),
                        onChanged: (_) {
                          if (errorCantidad != null) {
                            setState(() => errorCantidad = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: unidadSeleccionada,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'pza', child: Text('pza')),
                          DropdownMenuItem(value: 'M', child: Text('M')),
                          DropdownMenuItem(value: 'cm', child: Text('cm')),
                          DropdownMenuItem(value: 'mm', child: Text('mm')),
                          DropdownMenuItem(value: 'L', child: Text('L')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'm²', child: Text('m²')),
                          DropdownMenuItem(value: 'm³', child: Text('m³')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            unidadSeleccionada = value;
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: proyectoClave,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Proyecto (opcional)',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('— Ninguno —'),
                          ),
                          ...vm.proyectos.map(
                                (p) => DropdownMenuItem<String>(
                              value: p.clave,
                              child: Text(
                                '${p.clave} - ${p.nombre}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => proyectoClave = v),
                      ),
                      TextField(
                        controller: numeroParteController,
                        decoration: const InputDecoration(
                          labelText: 'Número de parte (opcional)',
                        ),
                      ),
                      TextField(
                        controller: observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones (opcional)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final nombre = nombreController.text.trim();
                    final cantidad =
                        double.tryParse(cantidadController.text) ?? 0;

                    // NUEVO: calcula y muestra los errores en vez de solo hacer return
                    final nuevoErrorNombre =
                    nombre.isEmpty ? 'Capture el nombre del item' : null;
                    final nuevoErrorCantidad = cantidad <= 0
                        ? 'Capture una cantidad válida'
                        : null;

                    if (nuevoErrorNombre != null || nuevoErrorCantidad != null) {
                      setState(() {
                        errorNombre = nuevoErrorNombre;
                        errorCantidad = nuevoErrorCantidad;
                      });
                      return;
                    }

                    vm.agregarItem(
                      CompraItem(
                        id: IdGenerator.generarCompraItemId(),
                        compraId: solicitud.id,
                        materialClave: materialClaveSeleccionada,
                        nombre: nombre,
                        proyectoClave: proyectoClave,
                        cantidad: cantidad,
                        unidad: unidadSeleccionada,
                        observaciones: observacionesController.text.trim().isEmpty
                            ? null
                            : observacionesController.text.trim(),
                        numeroParte: numeroParteController.text.trim().isEmpty
                            ? null
                            : numeroParteController.text.trim(),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _aprobar({
    required SolicitudCompra solicitud,
    required String ordenCompra,
    required TipoCompra tipoCompra,
    required void Function(bool guardando) setGuardando,
  }) async {
    if (ordenCompra.trim().isEmpty) return;

    setGuardando(true);

    final compra = await widget.viewModel.aprobar(
      solicitud: solicitud,
      ordenCompra: ordenCompra.trim(),
      tipoCompra: tipoCompra,
      compradorId: widget.usuarioId,
    );

    setGuardando(false);

    if (compra == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo aprobar la solicitud. Intenta de nuevo.')),
        );
      }
      return;
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _rechazar(
      SolicitudCompra solicitud, {
        required void Function(bool guardando) setGuardando,
      }) async {
    final motivoController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: TextField(
          controller: motivoController,
          decoration: const InputDecoration(labelText: 'Motivo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setGuardando(true);

    final ok = await widget.viewModel.rechazar(
      solicitud: solicitud,
      motivo: motivoController.text.trim(),
    );

    setGuardando(false);

    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo rechazar la solicitud. Intenta de nuevo.')),
        );
      }
      return;
    }

    if (mounted) Navigator.pop(context); // cierra el bottom sheet
  }
}