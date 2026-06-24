import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/models/Vale.dart';
import 'package:mi_almacen/models/Vale_Item.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';

class AprobacionValesPage extends StatefulWidget {
  final AprobacionValesViewModel viewModel;

  const AprobacionValesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<AprobacionValesPage> createState() =>
      _AprobacionValesPageState();
}

class _AprobacionValesPageState extends State<AprobacionValesPage> {
  final Map<String, ValeItem> _editableItems = {};

  @override
  void initState() {
    super.initState();
    widget.viewModel.cargarVales();
  }

  void _syncValeItems(Vale vale) {
    for (int i = 0; i < vale.items.length; i++) {
      final key = '${vale.id}_$i';
      _editableItems.putIfAbsent(
        key,
            () => ValeItem(
          material: vale.items[i].material,
          proyecto: vale.items[i].proyecto,
          cantidad: vale.items[i].cantidad,
          unidad: vale.items[i].unidad,
        ),
      );
    }
  }

  Vale _buildUpdatedVale(Vale original) {
    final updatedItems = <ValeItem>[];

    for (int i = 0; i < original.items.length; i++) {
      final key = '${original.id}_$i';
      final item = _editableItems[key];

      if (item != null) {
        updatedItems.add(item);
      }
    }

    return Vale(
      id: original.id,
      fechaCreacion: original.fechaCreacion,
      usuarioNombre: original.usuarioNombre,
      usuarioRol: original.usuarioRol,
      departamento: original.departamento,
      estado: original.estado,
      fechaValidacion: original.fechaValidacion,
      validadoPor: original.validadoPor,
      comentarioValidacion: original.comentarioValidacion,
      syncStatus: original.syncStatus,
      items: updatedItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final vales = widget.viewModel.vales;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Aprobación de Vales'),
          ),
          body: widget.viewModel.cargando
              ? const Center(child: CircularProgressIndicator())
              : vales.isEmpty
              ? const Center(child: Text('No hay vales pendientes'))
              : ListView.builder(
            itemCount: vales.length,
            itemBuilder: (context, index) {
              final vale = vales[index];

              _syncValeItems(vale);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Vale: ${vale.id}'),
                  subtitle:
                  Text('Usuario: ${vale.usuarioNombre}'),
                  children: [
                    const Divider(),

                    /// =========================
                    /// ITEMS
                    /// =========================
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Materiales:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...vale.items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;

                            final key = '${vale.id}_$i';
                            final editable =
                            _editableItems[key]!;

                            return Container(
                              margin:
                              const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  /// MATERIAL
                                  Text(
                                    'Material: ${editable.material.descripcion}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                      'Código: ${editable.material.codigo}'),

                                  const SizedBox(height: 8),

                                  /// PROYECTO EDITABLE
                                  DropdownButtonFormField<String>(
                                    value: editable.proyecto?.clave, // ✔ ahora es String

                                    decoration: const InputDecoration(
                                      labelText: 'Proyecto',
                                      border: OutlineInputBorder(),
                                    ),

                                    items: widget.viewModel.proyectos.map((p) {
                                      return DropdownMenuItem<String>(
                                        value: p.clave, // ✔ String correcto
                                        child: Text('${p.clave} - ${p.nombre}'),
                                      );
                                    }).toList(),

                                    onChanged: (value) {
                                      final proyecto = widget.viewModel.proyectos
                                          .firstWhere((p) => p.clave == value);

                                      setState(() {
                                        _editableItems[key] = ValeItem(
                                          material: editable.material,
                                          proyecto: proyecto, // ✔ regresas a objeto completo
                                          cantidad: editable.cantidad,
                                          unidad: editable.unidad,
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  /// CANTIDAD
                                  TextFormField(
                                    initialValue:
                                    editable.cantidad
                                        .toString(),
                                    keyboardType:
                                    TextInputType.number,
                                    decoration:
                                    const InputDecoration(
                                      labelText: 'Cantidad',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _editableItems[key] =
                                            ValeItem(
                                              material:
                                              editable.material,
                                              proyecto:
                                              editable.proyecto,
                                              cantidad:
                                              double.tryParse(
                                                  value) ??
                                                  editable.cantidad,
                                              unidad: editable.unidad,
                                            );
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 8),

                                  /// UNIDAD
                                  TextFormField(
                                    initialValue:
                                    editable.unidad,
                                    decoration:
                                    const InputDecoration(
                                      labelText: 'Unidad',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _editableItems[key] =
                                            ValeItem(
                                              material:
                                              editable.material,
                                              proyecto:
                                              editable.proyecto,
                                              cantidad:
                                              editable.cantidad,
                                              unidad: value,
                                            );
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  /// ELIMINAR
                                  Align(
                                    alignment:
                                    Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          vale.items.removeAt(i);
                                          _editableItems
                                              .remove(key);
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red),
                                      label: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                            color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(),

                          /// =========================
                          /// ACCIONES
                          /// =========================
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'aprobar') {
                                    _mostrarDialogoAccion(
                                      context,
                                      vale.id,
                                      true,
                                    );
                                  }

                                  if (value == 'rechazar') {
                                    _mostrarDialogoAccion(
                                      context,
                                      vale.id,
                                      false,
                                    );
                                  }

                                },

                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'aprobar',
                                    child: Text('Aprobar'),
                                  ),
                                  PopupMenuItem(
                                    value: 'rechazar',
                                    child: Text('Rechazar'),
                                  ),
                                ],
                                child:
                                const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoAccion(
      BuildContext context,
      String valeId,
      bool aprobar,
      ) async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aprobar ? 'Aprobar Vale' : 'Rechazar Vale'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Comentario',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(aprobar ? 'Aprobar' : 'Rechazar'),
          ),
        ],
      ),
    );

    if (ok == true) {

      final comentario = controller.text.trim();

      final valeOriginal = widget.viewModel.vales
          .firstWhere((v) => v.id == valeId);

      final valeEditado = _buildUpdatedVale(valeOriginal);

      // 1. Guardar cambios
      await widget.viewModel.actualizarVale(valeEditado);

      // 2. Aprobar o rechazar
      if (aprobar) {
        await widget.viewModel.aprobarVale(valeId, comentario);
      } else {
        await widget.viewModel.rechazarVale(valeId, comentario);
      }
    }

  }
}
