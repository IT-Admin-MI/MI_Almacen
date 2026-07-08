import 'package:flutter/material.dart';

import '../../models/Material.dart' as models;
import '../../models/Proyecto.dart';
import '../../viewmodels/admin_db_viewmodel.dart';

class _CampoConfig {
  final String key;
  final String label;
  final _TipoCampo tipo;
  final bool soloLectura;

  const _CampoConfig({
    required this.key,
    required this.label,
    this.tipo = _TipoCampo.texto,
    this.soloLectura = false,
  });
}

enum _TipoCampo {
  texto,
  entero,
  decimal,
  booleano,
  materialSelect,
  proyectoSelect,
  unidadSelect,
}

class AdminDbPage extends StatefulWidget {
  final AdminDbViewModel viewModel;

  const AdminDbPage({super.key, required this.viewModel});

  @override
  State<AdminDbPage> createState() => _AdminDbPageState();
}

class _AdminDbPageState extends State<AdminDbPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.cargarTodo();
  }

  static const _camposVale = [
    _CampoConfig(key: 'id', label: 'ID', soloLectura: true),
    _CampoConfig(key: 'fecha_creacion', label: 'Fecha creación', soloLectura: true),
    _CampoConfig(key: 'usuario_nombre', label: 'Usuario'),
    _CampoConfig(key: 'usuario_rol', label: 'Rol usuario', tipo: _TipoCampo.entero),
    _CampoConfig(key: 'departamento', label: 'Departamento'),
    _CampoConfig(key: 'estado', label: 'Estado (0/1/2)', tipo: _TipoCampo.entero),
    _CampoConfig(key: 'fecha_validacion', label: 'Fecha validación'),
    _CampoConfig(key: 'validado_por', label: 'Validado por'),
    _CampoConfig(key: 'comentario_validacion', label: 'Comentario'),
    _CampoConfig(key: 'liberado', label: 'Liberado (0/1)', tipo: _TipoCampo.entero),
  ];

  // material_codigo, proyecto_clave y proyecto_nombre no se listan como
  // campos de texto sueltos: se resuelven automáticamente a partir de los
  // selects de material y proyecto al guardar.
  static const _camposValeItem = [
    _CampoConfig(key: 'id', label: 'ID', soloLectura: true),
    _CampoConfig(key: 'vale_id', label: 'Vale ID', soloLectura: true),
    _CampoConfig(key: 'material_descripcion', label: 'Material', tipo: _TipoCampo.materialSelect),
    _CampoConfig(key: 'proyecto_clave', label: 'Proyecto', tipo: _TipoCampo.proyectoSelect),
    _CampoConfig(key: 'cantidad', label: 'Cantidad', tipo: _TipoCampo.decimal),
    _CampoConfig(key: 'unidad', label: 'Unidad', tipo: _TipoCampo.unidadSelect),
    _CampoConfig(key: 'comentario_vale', label: 'Comentario'),
  ];

  static const _camposProyecto = [
    _CampoConfig(key: 'clave', label: 'Clave', soloLectura: true),
    _CampoConfig(key: 'nombre', label: 'Nombre'),
    _CampoConfig(key: 'orden', label: 'Orden', tipo: _TipoCampo.entero),
    _CampoConfig(key: 'status', label: 'Activo', tipo: _TipoCampo.booleano),
    _CampoConfig(key: 'fechaEntrega', label: 'Fecha entrega (ISO8601)'),
  ];

  static const _unidades = ['pza', 'M', 'cm', 'mm', 'L', 'ml'];

  Future<void> _editarFila({

    required Map<String, dynamic> fila,
    required List<_CampoConfig> campos,
    required String titulo,
    required Future<void> Function(Map<String, dynamic>) onGuardar,
    List<models.Material>? materiales,
    List<Proyecto>? proyectosCatalogo,
  }) async {
    print('FILA RECIBIDA: $fila');
    final controladores = <String, TextEditingController>{};
    final booleanos = <String, bool>{};

    Proyecto? proyectoSeleccionado;
    String? unidadSeleccionada;

    // Para el campo de material: código editable + descripción calculada.
    final materialCodigoController =
    TextEditingController(text: fila['material_codigo']?.toString() ?? '');
    String descripcionMaterialActual =
        fila['material_descripcion']?.toString() ?? '';
    bool codigoMaterialValido = true;

    void actualizarDescripcionMaterial(
        String codigo, void Function(void Function()) setDialogState) {
      final encontrado = (materiales ?? [])
          .where((m) => m.codigo == codigo)
          .firstOrNull;

      setDialogState(() {
        if (encontrado != null) {
          descripcionMaterialActual = encontrado.descripcion;
          codigoMaterialValido = true;
        } else {
          // Código vacío no se marca como error; código no vacío pero
          // sin coincidencia en catálogo sí se marca como inválido.
          codigoMaterialValido = codigo.trim().isEmpty;
        }
      });
    }

    for (final campo in campos) {
      switch (campo.tipo) {
        case _TipoCampo.booleano:
          final valor = fila[campo.key];
          booleanos[campo.key] = valor == true || valor == 1;
          break;

        case _TipoCampo.materialSelect:
        // Manejado arriba con materialCodigoController.
          break;

        case _TipoCampo.proyectoSelect:
          final claveActual = fila['proyecto_clave'];
          if (proyectosCatalogo != null) {
            for (final p in proyectosCatalogo) {
              if (p.clave == claveActual) {
                proyectoSeleccionado = p;
                break;
              }
            }
          }
          break;

        case _TipoCampo.unidadSelect:
          unidadSeleccionada = fila['unidad'] as String?;
          break;

        default:
          controladores[campo.key] =
              TextEditingController(text: fila[campo.key]?.toString() ?? '');
      }
    }

    bool guardando = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: campos.map((campo) {
                    switch (campo.tipo) {
                      case _TipoCampo.booleano:
                        return SwitchListTile(
                          title: Text(campo.label),
                          value: booleanos[campo.key] ?? false,
                          onChanged: campo.soloLectura
                              ? null
                              : (val) => setDialogState(
                                  () => booleanos[campo.key] = val),
                          contentPadding: EdgeInsets.zero,
                        );

                      case _TipoCampo.materialSelect:
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descripción actual',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                descripcionMaterialActual.isEmpty
                                    ? '(sin descripción)'
                                    : descripcionMaterialActual,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: materialCodigoController,
                                enabled: !campo.soloLectura,
                                decoration: InputDecoration(
                                  labelText: 'Código material',
                                  border: const OutlineInputBorder(),
                                  errorText: codigoMaterialValido
                                      ? null
                                      : 'Código no encontrado en catálogo',
                                ),
                                onChanged: campo.soloLectura
                                    ? null
                                    : (valor) => actualizarDescripcionMaterial(
                                    valor.trim(), setDialogState),
                              ),
                            ],
                          ),
                        );

                      case _TipoCampo.proyectoSelect:
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<Proyecto>(
                            value: proyectoSeleccionado,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: campo.label,
                              border: const OutlineInputBorder(),
                            ),
                            items: (proyectosCatalogo ?? []).map((p) {
                              return DropdownMenuItem<Proyecto>(
                                value: p,
                                child: Text(
                                  '${p.clave} - ${p.nombre}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: campo.soloLectura
                                ? null
                                : (p) => setDialogState(
                                    () => proyectoSeleccionado = p),
                          ),
                        );

                      case _TipoCampo.unidadSelect:
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: _unidades.contains(unidadSeleccionada)
                                ? unidadSeleccionada
                                : null,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: campo.label,
                              border: const OutlineInputBorder(),
                            ),
                            items: _unidades
                                .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u),
                            ))
                                .toList(),
                            onChanged: campo.soloLectura
                                ? null
                                : (u) => setDialogState(
                                    () => unidadSeleccionada = u),
                          ),
                        );

                      default:
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: controladores[campo.key],
                            enabled: !campo.soloLectura,
                            keyboardType: campo.tipo == _TipoCampo.entero ||
                                campo.tipo == _TipoCampo.decimal
                                ? const TextInputType.numberWithOptions(
                                decimal: true)
                                : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: campo.label,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                    }
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                    setDialogState(() => guardando = true);

                    final filaActualizada = <String, dynamic>{...fila};

                    for (final campo in campos) {
                      if (campo.soloLectura) continue;

                      switch (campo.tipo) {
                        case _TipoCampo.booleano:
                          filaActualizada[campo.key] =
                          (booleanos[campo.key] ?? false) ? 1 : 0;
                          break;

                        case _TipoCampo.materialSelect:
                          final codigoIngresado =
                          materialCodigoController.text.trim();
                          final materialEncontrado = (materiales ?? [])
                              .where((m) => m.codigo == codigoIngresado)
                              .firstOrNull;

                          filaActualizada['material_codigo'] = codigoIngresado;
                          filaActualizada['material_descripcion'] =
                              materialEncontrado?.descripcion ??
                                  fila['material_descripcion'];
                          break;

                        case _TipoCampo.proyectoSelect:
                          final proyecto = proyectoSeleccionado;
                          if (proyecto != null) {
                            filaActualizada['proyecto_clave'] =
                                proyecto.clave;
                            filaActualizada['proyecto_nombre'] =
                                proyecto.nombre;
                          }
                          break;

                        case _TipoCampo.unidadSelect:
                          filaActualizada['unidad'] = unidadSeleccionada;
                          break;

                        case _TipoCampo.entero:
                          filaActualizada[campo.key] = int.tryParse(
                              controladores[campo.key]!.text.trim()) ??
                              0;
                          break;

                        case _TipoCampo.decimal:
                          filaActualizada[campo.key] = double.tryParse(
                              controladores[campo.key]!.text.trim()) ??
                              0.0;
                          break;

                        case _TipoCampo.texto:
                          final texto =
                          controladores[campo.key]!.text.trim();
                          filaActualizada[campo.key] =
                          texto.isEmpty ? null : texto;
                          break;
                      }
                    }

                    await onGuardar(filaActualizada);

                    if (mounted) Navigator.pop(context);
                  },
                  child: guardando
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _listaGenerica({
    required List<Map<String, dynamic>> filas,
    required List<_CampoConfig> campos,
    required String tituloClave,
    required String subtituloClave,
    required Future<void> Function(Map<String, dynamic>) onGuardar,
    required Future<void> Function() onRefresh,
    List<models.Material>? materiales,
    List<Proyecto>? proyectosCatalogo,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await onRefresh();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronizado correctamente')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al sincronizar')),
          );
        }
      },
        child: filas.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 200),
            Center(
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
                    'No existen elementos en la base de datos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )

        : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filas.length,
        itemBuilder: (context, index) {
          final fila = filas[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${fila[tituloClave]}'),
              subtitle: Text('${fila[subtituloClave] ?? ''}'),
              trailing: const Icon(Icons.edit_note_rounded),
              onTap: () => _editarFila(
                fila: fila,
                campos: campos,
                titulo: 'Editar registro',
                onGuardar: onGuardar,
                materiales: materiales,
                proyectosCatalogo: proyectosCatalogo,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo_ext.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vales'),
              Tab(text: 'Items'),
              Tab(text: 'Proyectos'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: widget.viewModel,
          builder: (context, _) {
            if (widget.viewModel.cargando) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (widget.viewModel.error != null) {
              return Center(
                child: Text(widget.viewModel.error!),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _listaGenerica(
                        filas: widget.viewModel.vales,
                        campos: _camposVale,
                        tituloClave: 'id',
                        subtituloClave: 'usuario_nombre',
                        onGuardar: widget.viewModel.guardarVale,
                        onRefresh: widget.viewModel.sincronizarVales,
                      ),
                      _listaGenerica(
                        filas: widget.viewModel.valeItems,
                        campos: _camposValeItem,
                        tituloClave: 'material_descripcion',
                        subtituloClave: 'vale_id',
                        onGuardar: widget.viewModel.guardarValeItem,
                        onRefresh: widget.viewModel.cargarTodo,
                        materiales: widget.viewModel.materiales,
                        proyectosCatalogo: widget.viewModel.proyectosCatalogo,
                      ),
                      _listaGenerica(
                        filas: widget.viewModel.proyectos,
                        campos: _camposProyecto,
                        tituloClave: 'clave',
                        subtituloClave: 'nombre',
                        onGuardar: widget.viewModel.guardarProyecto,
                        onRefresh: widget.viewModel.sincronizarProyectos,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: widget.viewModel.cargarTodo,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}