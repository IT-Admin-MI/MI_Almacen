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
  bool _refrescando = false;
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.cargarVales();
  }

  void _onViewModelChanged() {
    for (final vale in widget.viewModel.vales) {
      _syncValeItems(vale);
    }
    setState(() {}); // ahora sí actualiza el estado
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }
  void _syncValeItems(Vale vale) {
    for (final item in vale.items) {
      final key = '${vale.id}_${item.material.codigo}';
      final editable = _editableItems[key];
      print('guardando key: $key');
      _editableItems.putIfAbsent(
        key,
            () => ValeItem(
          material: item.material,
          proyecto: item.proyecto,
          cantidad: item.cantidad,
          unidad: item.unidad,
              comentarioVale: item.comentarioVale,
        ),
      );
    }
  }

  Vale _buildUpdatedVale(Vale original) {
    final updatedItems = <ValeItem>[];

    for (final item in original.items) {
      final key = '${original.id}_${item.material.codigo}'; // ← código, no índice
      final editedItem = _editableItems[key];
      if (editedItem != null) {
        updatedItems.add(editedItem);
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
      liberado: original.liberado,
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
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() => _refrescando = true);
              await widget.viewModel.actualizar();
              if (mounted) setState(() => _refrescando = false);
            },
            child: (widget.viewModel.cargando && !_refrescando)
                ? const Center(child: CircularProgressIndicator())
                : vales.isEmpty
          ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/logo_bn.png',
                  width: 180,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay vales pendientes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
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

                              final key = '${vale.id}_${item.material.codigo}';
                              final editable = _editableItems[key];
                              if (editable == null) {
                                print('Editable NULL para key: $key');
                                return const SizedBox();
                              }

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
                                      '${editable.material.descripcion}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                        'Código: ${editable.material.codigo}'),

                                    const SizedBox(height: 8),
                                    /// PROYECTO EDITABLE
                                    DropdownButtonFormField<String>(
                                      value: editable.proyecto?.clave,
                                      isExpanded: true, // ← esto es lo más importante
                                      decoration: const InputDecoration(
                                        labelText: 'Proyecto',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: widget.viewModel.proyectos.map((p) {
                                        return DropdownMenuItem<String>(
                                          value: p.clave,
                                          child: Text(
                                            '${p.clave} - ${p.nombre}',
                                            overflow: TextOverflow.ellipsis, // ← corta el texto si es largo
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        final proyecto = widget.viewModel.proyectos
                                            .firstWhere((p) => p.clave == value);
                                        setState(() {
                                          _editableItems[key] = ValeItem(
                                            material: editable.material,
                                            proyecto: proyecto,
                                            cantidad: editable.cantidad,
                                            unidad: editable.unidad,
                                            comentarioVale: editable.comentarioVale,
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
                                                comentarioVale: editable.comentarioVale,
                                              );
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    /// UNIDAD
                                    SizedBox(
                                      width: 100,
                                      child: DropdownButtonFormField<String>(
                                        value: item.unidad,  // ← item, no editable
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(fontSize: 13, color: Colors.black),
                                        decoration: const InputDecoration(
                                          labelText: 'Unidad',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          isDense: true,
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: 'pza', child: Text('pza')),
                                          DropdownMenuItem(value: 'M',   child: Text('M')),
                                          DropdownMenuItem(value: 'cm',  child: Text('cm')),
                                          DropdownMenuItem(value: 'mm',  child: Text('mm')),
                                          DropdownMenuItem(value: 'L',   child: Text('L')),
                                          DropdownMenuItem(value: 'ml',  child: Text('ml')),
                                        ],
                                        onChanged: (value) {
                                          if (value == null) return;
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
                                                  comentarioVale: editable.comentarioVale,
                                                );
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    TextFormField(
                                      initialValue: editable.comentarioVale,
                                      decoration: const InputDecoration(
                                        labelText: 'Comentario',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 2,
                                      onChanged: (value) {
                                        setState(() {
                                          _editableItems[key] = ValeItem(
                                            material: editable.material,
                                            proyecto: editable.proyecto,
                                            cantidad: editable.cantidad,
                                            unidad: editable.unidad,
                                            comentarioVale: value,
                                          );
                                        });
                                      },
                                    ),


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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _mostrarDialogoAccion(context, vale.id, false),
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                                  label: const Text('Rechazar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(130, 40),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _mostrarDialogoAccion(context, vale.id, true),
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                  label: const Text('Aprobar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(130, 40),
                                  ),
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
