import 'package:flutter/material.dart';
import 'package:mi_almacen/models/Compra.dart';
import 'package:mi_almacen/models/CompraItem.dart';
import 'package:mi_almacen/models/Proyecto.dart';
import 'package:mi_almacen/viewmodels/compra_viewmodel.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ComprasPage extends StatefulWidget {

  final CompraViewModel viewModel;

  const ComprasPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  late CompraViewModel viewModel;


  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;
    viewModel.cargarCompras();
    viewModel.cargarProyectos();
  }

  // ============================================================
  // compraExistente == null  -> modo creación
  // compraExistente != null  -> modo edición (precarga todo)
  // ============================================================
  Future<void> _mostrarDialogNuevaCompra({
    Compra? compraExistente,
  }) async {

    final esEdicion = compraExistente != null;

    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController(
      text: compraExistente?.nombre ?? "",
    );

    final descripcionController = TextEditingController(
      text: compraExistente?.descripcion ?? "",
    );

    final ordenCompraController = TextEditingController(
      text: compraExistente?.ordenCompra ?? "",
    );

    // ---- Controllers para AGREGAR un material nuevo ----
    final itemNombreController = TextEditingController();
    final itemMaterialClaveController = TextEditingController();
    final buscadorMaterialController = TextEditingController();
    final itemProyectoClaveController = TextEditingController();
    final cantidadController = TextEditingController();
    final unidadController = TextEditingController(text: "Pza");

    // ---- Controllers para EDITAR un material ya agregado ----
    final editNombreController = TextEditingController();
    final editMaterialClaveController = TextEditingController();
    final editProyectoClaveController = TextEditingController();
    final editCantidadController = TextEditingController();
    final editUnidadController = TextEditingController();

    // Si es edición, partimos de una COPIA de los items existentes,
    // para no mutar la compra original hasta que se confirme "Guardar".
    final itemsTemporales = <CompraItem>[
      if (esEdicion) ...compraExistente.items,
    ];

    String? errorItems;
    String? errorEdicion;
    DateTime? fechaEntrega = compraExistente?.fechaEntrega;
    bool materialSeleccionado = false;

    // Controla si el formulario de "Agregar material" está visible.
    bool mostrarFormularioAgregar = false;

    // Índice del material que está expandido para edición (null = ninguno).
    int? indexEditando;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, _) {
            return StatefulBuilder(
              builder: (context, setDialogState) {

                void agregarItem() {
                  final nombre = itemNombreController.text.trim();
                  final unidad = unidadController.text.trim();
                  final cantidad = double.tryParse(
                    cantidadController.text.trim(),
                  );

                  if (nombre.isEmpty ||
                      unidad.isEmpty ||
                      cantidad == null ||
                      cantidad <= 0) {
                    setDialogState(() {
                      errorItems = "Completa material, cantidad válida y unidad";
                    });

                    return;
                  }

                  final materialClave =
                  itemMaterialClaveController.text.trim();

                  final proyectoClave =
                  itemProyectoClaveController.text.trim();

                  setDialogState(() {
                    errorItems = null;

                    itemsTemporales.add(
                      CompraItem(
                        compraId: "",
                        materialClave:
                        materialClave.isEmpty ? null : materialClave,
                        nombre: nombre,
                        proyectoClave:
                        proyectoClave.isEmpty ? null : proyectoClave,
                        cantidad: cantidad,
                        unidad: unidad,
                      ),
                    );

                    itemNombreController.clear();
                    itemMaterialClaveController.clear();
                    itemProyectoClaveController.clear();
                    cantidadController.clear();
                    unidadController.text = "Pza";
                    materialSeleccionado = false;
                  });
                }

                void abrirEdicionItem(int index) {

                  final item = itemsTemporales[index];

                  editNombreController.text = item.nombre;
                  editMaterialClaveController.text =
                      item.materialClave ?? "";
                  editProyectoClaveController.text =
                      item.proyectoClave ?? "";
                  editCantidadController.text =
                      item.cantidad.toString();
                  editUnidadController.text = item.unidad;

                  setDialogState(() {
                    errorEdicion = null;
                    indexEditando = index;
                  });

                }

                void cancelarEdicionItem() {
                  setDialogState(() {
                    indexEditando = null;
                    errorEdicion = null;
                  });
                }

                void guardarEdicionItem(int index) {

                  final nombre = editNombreController.text.trim();
                  final unidad = editUnidadController.text.trim();
                  final cantidad = double.tryParse(
                    editCantidadController.text.trim(),
                  );

                  if (nombre.isEmpty ||
                      unidad.isEmpty ||
                      cantidad == null ||
                      cantidad <= 0) {
                    setDialogState(() {
                      errorEdicion =
                      "Completa material, cantidad válida y unidad";
                    });
                    return;
                  }

                  final materialClave =
                  editMaterialClaveController.text.trim();

                  final proyectoClave =
                  editProyectoClaveController.text.trim();

                  setDialogState(() {

                    final original = itemsTemporales[index];

                    // Se reconstruye directo (no con copyWith) porque
                    // copyWith no permite "limpiar" un campo a null:
                    // usa el patrón `valor ?? this.valor`, así que pasar
                    // null ahí conservaría el valor anterior.
                    itemsTemporales[index] = CompraItem(
                      id: original.id,
                      compraId: original.compraId,
                      materialClave:
                      materialClave.isEmpty ? null : materialClave,
                      nombre: nombre,
                      proyectoClave:
                      proyectoClave.isEmpty ? null : proyectoClave,
                      cantidad: cantidad,
                      unidad: unidad,
                    );

                    indexEditando = null;
                    errorEdicion = null;

                  });

                }

                Future<void> seleccionarFechaEntrega() async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: fechaEntrega ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (fecha != null) {
                    setDialogState(() {
                      fechaEntrega = fecha;
                    });
                  }
                }

                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    esEdicion ? "Editar compra" : "Nueva compra",
                  ),

                  content: SizedBox(

                    width: double.maxFinite,

                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(

                        child: Column(

                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            // ===================== DATOS GENERALES =====================

                            Text(
                              "Datos generales",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextFormField(
                              controller: nombreController,
                              decoration: const InputDecoration(
                                labelText: "Nombre compra",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? "Requerido"
                                  : null,
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: descripcionController,
                              decoration: const InputDecoration(
                                labelText: "Descripción",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: ordenCompraController,
                              decoration: const InputDecoration(
                                labelText: "Orden de compra",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    fechaEntrega == null
                                        ? "Sin fecha de entrega"
                                        : "Entrega: "
                                        "${DateFormat('dd/MM/yyyy').format(
                                      fechaEntrega!,
                                    )}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),

                                TextButton(
                                  onPressed: seleccionarFechaEntrega,
                                  child: const Text(
                                    "Elegir fecha",
                                  ),
                                ),

                                if (fechaEntrega != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setDialogState(() {
                                        fechaEntrega = null;
                                      });
                                    },
                                  ),

                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(thickness: 1),
                            const SizedBox(height: 8),

                            // ================= MATERIALES: ENCABEZADO =================

                            LayoutBuilder(
                              builder: (context, constraints) {

                                // En pantallas angostas (celular) el botón solo muestra
                                // el ícono; en pantallas anchas (tablet/Windows) muestra
                                // ícono + texto.
                                final anchoReducido = constraints.maxWidth < 360;

                                return Row(
                                  children: [

                                    Expanded(
                                      child: Row(
                                        children: [

                                          Flexible(
                                            child: Text(
                                              "Materiales: ",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${itemsTemporales.length}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    anchoReducido
                                        ? IconButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          mostrarFormularioAgregar = !mostrarFormularioAgregar;
                                          if (mostrarFormularioAgregar) {
                                            indexEditando = null;
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        mostrarFormularioAgregar ? Icons.close : Icons.add,
                                      ),
                                      tooltip: mostrarFormularioAgregar
                                          ? "Cerrar"
                                          : "Agregar material",
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                        Theme.of(context).colorScheme.primaryContainer,
                                      ),
                                    )
                                        : TextButton.icon(
                                      onPressed: () {
                                        setDialogState(() {
                                          mostrarFormularioAgregar = !mostrarFormularioAgregar;
                                          if (mostrarFormularioAgregar) {
                                            indexEditando = null;
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        mostrarFormularioAgregar ? Icons.close : Icons.add,
                                      ),
                                      label: Text(
                                        mostrarFormularioAgregar ? "Cerrar" : "Agregar material",
                                      ),
                                    ),

                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Toca un material para ver o editar sus datos.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ================= FORMULARIO: AGREGAR MATERIAL =================
                            // Solo visible si el usuario tocó "Agregar material".

                            if (mostrarFormularioAgregar)

                              Container(

                                margin: const EdgeInsets.only(bottom: 16),

                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade50,
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "Nuevo material",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    DropdownButtonFormField<Proyecto>(

                                      isExpanded: true,  // 👈 ocupa el ancho disponible en vez del ancho intrínseco

                                      value: itemProyectoClaveController.text.isEmpty
                                          ? null
                                          : viewModel.proyectos
                                          .where(
                                            (p) =>
                                        p.clave ==
                                            itemProyectoClaveController.text,
                                      )
                                          .firstOrNull,

                                      decoration: const InputDecoration(
                                        labelText: "Proyecto ",
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 12,
                                        ),
                                        isDense: true,
                                      ),

                                      dropdownColor: Colors.white,

                                      items: viewModel.proyectos.map(
                                            (proyecto) {

                                          return DropdownMenuItem<Proyecto>(

                                            value: proyecto,

                                            // Ya no se necesita el SizedBox con MediaQuery: con
                                            // isExpanded:true el propio dropdown recorta el ancho.
                                            child: Text(

                                              '${proyecto.clave} - ${proyecto.nombre}',

                                              overflow:
                                              TextOverflow.ellipsis,

                                              maxLines: 1,

                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),

                                            ),

                                          );

                                        },

                                      ).toList(),

                                      onChanged: (proyecto) {

                                        setDialogState(() {

                                          itemProyectoClaveController.text =
                                              proyecto?.clave ?? "";

                                        });

                                      },

                                    ),

                                    const SizedBox(height: 10),

                                    TextField(
                                      controller: itemNombreController,

                                      readOnly: materialSeleccionado,

                                      decoration: InputDecoration(
                                        labelText: "Nombre de material",
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        fillColor: materialSeleccionado
                                            ? Colors.grey.shade200
                                            : Colors.white,
                                        isDense: true,
                                        suffixIcon: materialSeleccionado
                                            ? const Icon(Icons.lock_outline)
                                            : null,
                                      ),
                                    ),

                                    if (materialSeleccionado)

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          icon: const Icon(Icons.clear, size: 18),
                                          label: const Text(
                                            "Quitar material seleccionado",
                                          ),
                                          onPressed: () {
                                            setDialogState(() {
                                              materialSeleccionado = false;
                                              itemMaterialClaveController.clear();
                                              itemNombreController.clear();
                                            });
                                          },
                                        ),
                                      ),

                                    const SizedBox(height: 12),

                                    // El TextField del buscador de material
                                    TextField(
                                      controller: buscadorMaterialController,
                                      decoration: const InputDecoration(
                                        labelText: 'Buscar material (opcional)',
                                        hintText: 'Código o descripción',
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                      ),
                                      onChanged: (texto) async {
                                        await viewModel.buscarMaterial(texto);
                                        if (context.mounted) {
                                          setDialogState(() {});
                                        }
                                      },
                                    ),

                                    if (viewModel.resultadosBusqueda.isNotEmpty) ...[

                                      const SizedBox(height: 6),

                                      Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                          color: Colors.white,
                                        ),

                                        child: ListView.builder(

                                          shrinkWrap: true,

                                          itemCount:
                                          viewModel.resultadosBusqueda.length,

                                          itemBuilder: (_, index) {
                                            final material =
                                            viewModel.resultadosBusqueda[index];

                                            return ListTile(

                                              dense: true,

                                              title: Text(
                                                material.descripcion,
                                              ),

                                              subtitle: Text(
                                                material.codigo,
                                              ),

                                              // Al seleccionar un resultado de la búsqueda
                                              onTap: () {
                                                viewModel.limpiarBusquedaMaterial();

                                                setDialogState(() {
                                                  itemMaterialClaveController.text = material.codigo;
                                                  itemNombreController.text = material.descripcion;
                                                  materialSeleccionado = true;
                                                  buscadorMaterialController.clear();
                                                });
                                              },
                                            );
                                          },

                                        ),

                                      ),

                                    ],

                                    const SizedBox(height: 12),

                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Expanded(
                                          child: TextField(
                                            controller: cantidadController,
                                            keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: "Cantidad",
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: TextFormField(
                                            controller: unidadController,

                                            decoration: const InputDecoration(
                                              labelText: "Unidad",
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 8,
                                              ),
                                              isDense: true,
                                            ),

                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return "Requerido";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.icon(
                                        onPressed: agregarItem,
                                        icon: const Icon(Icons.add),
                                        label: const Text("Agregar"),
                                      ),
                                    ),

                                    if (errorItems != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        errorItems!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],

                                  ],
                                ),

                              ),

                            // ================= LISTA DE MATERIALES =================

                            if (itemsTemporales.isEmpty)

                              Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Aún no has agregado materiales",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              )

                            else

                              ListView.separated(

                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),

                                itemCount: itemsTemporales.length,

                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),

                                itemBuilder: (_, index) {

                                  final item = itemsTemporales[index];
                                  final expandido = indexEditando == index;

                                  return Container(

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: expandido
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey.shade300,
                                        width: expandido ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    child: expandido
                                        ? Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        const SizedBox(height: 8),

                                        Text(
                                          "Editando material",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        DropdownButtonFormField<Proyecto>(

                                          isExpanded: true,

                                          value: editProyectoClaveController
                                              .text.isEmpty
                                              ? null
                                              : viewModel.proyectos
                                              .where(
                                                (p) =>
                                            p.clave ==
                                                editProyectoClaveController.text,
                                          )
                                              .firstOrNull,

                                          decoration: const InputDecoration(
                                            labelText: "Proyecto",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 12,
                                            ),
                                            isDense: true,
                                          ),

                                          dropdownColor: Colors.white,

                                          items: viewModel.proyectos.map(
                                                (proyecto) {
                                              return DropdownMenuItem<Proyecto>(
                                                value: proyecto,
                                                child: Text(
                                                  '${proyecto.clave} - ${proyecto.nombre}',
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),

                                          onChanged: (proyecto) {
                                            setDialogState(() {
                                              editProyectoClaveController.text =
                                                  proyecto?.clave ?? "";
                                            });
                                          },

                                        ),

                                        const SizedBox(height: 10),

                                        TextField(
                                          controller: editNombreController,
                                          decoration: const InputDecoration(
                                            labelText: "Nombre de material",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        TextField(
                                          controller:
                                          editMaterialClaveController,
                                          decoration: const InputDecoration(
                                            labelText:
                                            "Clave de material (opcional)",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [

                                            Expanded(
                                              child: TextField(
                                                controller:
                                                editCantidadController,
                                                keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "Cantidad",
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Expanded(
                                              child: TextField(
                                                controller:
                                                editUnidadController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "Unidad",
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),

                                        if (errorEdicion != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            errorEdicion!,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 10),

                                        Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          runSpacing: 8,
                                          spacing: 8,
                                          children: [

                                            TextButton.icon(
                                              onPressed: () {
                                                setDialogState(() {
                                                  itemsTemporales.removeAt(index);
                                                  indexEditando = null;
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                "Eliminar",
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),

                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                                TextButton(
                                                  onPressed: cancelarEdicionItem,
                                                  child: const Text("Cancelar"),
                                                ),

                                                const SizedBox(width: 6),

                                                FilledButton(
                                                  onPressed: () => guardarEdicionItem(index),
                                                  child: const Text("Guardar"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                      ],
                                    )
                                        : ListTile(

                                      contentPadding: EdgeInsets.zero,

                                      dense: true,

                                      onTap: () => abrirEdicionItem(index),

                                      title: Text(
                                        item.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      subtitle: Text(
                                        "${item.cantidad} ${item.unidad}"
                                            "${item.materialClave != null
                                            ? ' · clave: ${item.materialClave}'
                                            : ''}"
                                            "${item.proyectoClave != null
                                            ? ' · proy: ${item.proyectoClave}'
                                            : ''}",
                                        style: const TextStyle(fontSize: 12),
                                      ),

                                      trailing: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                      ),

                                    ),

                                  );
                                },

                              ),

                          ],

                        ),

                      ),

                    ),

                  ),

                  actions: [

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancelar",
                      ),
                    ),

                    ElevatedButton(

                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        if (itemsTemporales.isEmpty) {
                          setDialogState(() {
                            errorItems = "Agrega al menos un material";
                          });
                          return;
                        }

                        final id = compraExistente?.id ?? const Uuid().v4();

                        final compra = Compra(
                          id: id,
                          nombre: nombreController.text.trim(),
                          descripcion:
                          descripcionController.text.trim(),
                          ordenCompra:
                          ordenCompraController.text.trim(),
                          fechaSolicitud:
                          compraExistente?.fechaSolicitud ?? DateTime.now(),
                          fechaEntrega: fechaEntrega,
                          estado:
                          compraExistente?.estado ?? EstadoCompra.solicitado,
                          estatus: compraExistente?.estatus ?? 1,
                          items: itemsTemporales
                              .map(
                                (item) => item.copyWith(compraId: id),
                          )
                              .toList(),
                          sync_status: 0,
                        );

                        if (esEdicion) {
                          await viewModel.actualizarCompra(compra);
                        } else {
                          await viewModel.crearCompra(compra);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },

                      child: Text(
                        esEdicion ? "Guardar cambios" : "Guardar compra",
                      ),

                    ),

                  ],

                );
              },

            );
          },
        );
      },
    );  // cierre de showDialog

    WidgetsBinding.instance.addPostFrameCallback((_) {
    nombreController.dispose();
    descripcionController.dispose();
    ordenCompraController.dispose();
    itemNombreController.dispose();
    itemMaterialClaveController.dispose();
    itemProyectoClaveController.dispose();
    cantidadController.dispose();
    unidadController.dispose();
    editNombreController.dispose();
    editMaterialClaveController.dispose();
    editProyectoClaveController.dispose();
    editCantidadController.dispose();
    editUnidadController.dispose();
    });
  }



  Future<void> _confirmarEliminarCompra(Compra compra) async {

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar compra"),
          content: Text(
            '¿Seguro que quieres eliminar "${compra.nombre}"? '
                'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      await viewModel.eliminarCompra(compra.id!);
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Administrar Compras"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogNuevaCompra(),
        child: const Icon(Icons.add),
      ),

      body: AnimatedBuilder(

        animation: viewModel,

        builder: (_, __) {

          if (viewModel.loading) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (viewModel.compras.isEmpty) {

            return const Center(
              child: Text(
                "No hay compras registradas",
              ),
            );

          }

          return ListView.builder(

            itemCount: viewModel.compras.length,

            itemBuilder: (_, index) {

              final compra = viewModel.compras[index];

              return ListTile(

                title: Text(
                  compra.nombre,
                ),

                subtitle: Text(
                  compra.estado.name,
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmarEliminarCompra(compra),
                    ),

                    const Icon(
                      Icons.chevron_right,
                    ),

                  ],
                ),

                onTap: () {

                  viewModel.seleccionarCompra(
                    compra,
                  );

                  _mostrarDialogNuevaCompra(
                    compraExistente: compra,
                  );

                },

              );

            },

          );

        },

      ),

    );

  }

}