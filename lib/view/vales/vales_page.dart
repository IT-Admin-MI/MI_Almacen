import 'package:flutter/material.dart';

import '../../models/Material.dart';
import '../../models/Proyecto.dart';
import '../../models/Vale_Item.dart';
import '../../viewmodels/vale_viewmodel.dart';

class ValesPage extends StatefulWidget {

  final ValeViewModel viewModel;

  const ValesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<ValesPage> createState() =>
      _ValesPageState();
}

class _ValesPageState
    extends State<ValesPage> {

  final TextEditingController
  buscadorController =
  TextEditingController();

  ValeViewModel get viewModel =>
      widget.viewModel;

  @override
  void initState() {

    super.initState();

    viewModel.addListener(
      actualizar,
    );

    viewModel.inicializar();
  }

  @override
  void dispose() {

    viewModel.removeListener(
      actualizar,
    );

    buscadorController.dispose();

    super.dispose();
  }

  void actualizar() {

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Image.asset(
          'assets/images/logo_ext.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
      const Center(
        child: Text(
          'Crear vale',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),          // ── ÁREA SUPERIOR ──────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.42,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  await viewModel.sincronizarMateriales();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inventario actualizado correctamente'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al actualizar el inventario'),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // LEYENDA DE ACTUALIZACIÓN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_down, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Desliza aquí para actualizar el inventario',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // BUSCADOR
                    TextField(
                      controller: buscadorController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar material',
                        hintText: 'Código o descripción',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: viewModel.buscarMaterial,
                    ),

                    const SizedBox(height: 10),

                    // RESULTADOS BÚSQUEDA
                    if (viewModel.resultadosBusqueda.isNotEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: viewModel.resultadosBusqueda.length,
                            itemBuilder: (context, index) {
                              final material = viewModel.resultadosBusqueda[index];
                              return ListTile(
                                title: Text(material.descripcion),
                                subtitle: Text(material.codigo),
                                trailing: Text(material.existencia.toString()),
                                onTap: () {
                                  viewModel.agregarMaterial(material);
                                  buscadorController.clear();
                                },
                              );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // ── LISTA VALE ITEMS ───────────────────────────
          Expanded(
            child: viewModel.items.isEmpty
                ? Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (viewModel.resultadosBusqueda.isEmpty) ...[
                      Image.asset(
                        'assets/images/logo_bn.png',
                        width: 100,
                        color: Colors.grey.withOpacity(0.4),
                        colorBlendMode: BlendMode.modulate,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Sin materiales agregados',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(viewModel.items[index]);
              },
            ),
          ),
          // ── BOTÓN CREAR VALE ───────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.puedeCrearVale && !viewModel.creandoVale
                      ? () async {
                    final resultado = await viewModel.crearVale();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(resultado
                            ? 'Vale creado correctamente'
                            : 'Error al crear el vale'),
                      ),
                    );
                  }
                      : null,
                  child: const Text('Crear Vale'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ValeItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Nombre + botón eliminar
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.material.descripcion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => viewModel.eliminarMaterial(item),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Código y existencia en la misma fila
            Row(
              children: [
                Text(
                  'Cód: ${item.material.codigo}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  'Exist: ${item.material.existencia}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Cantidad y Unidad en la misma fila
            Row(
              children: [
                // Cantidad
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: item.cantidad.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) {
                      final cantidad = double.tryParse(value);
                      if (cantidad == null) return;
                      viewModel.actualizarCantidad(item, cantidad);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Unidad
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    value: item.unidad,
                    dropdownColor: Colors.white,  // ← agrega esto
                    style: const TextStyle(fontSize: 13, color: Colors.black), // ← color explícito
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
                      viewModel.actualizarUnidad(item, value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Proyecto (ancho completo)
            DropdownButtonFormField<Proyecto>(
              value: viewModel.proyectos
                  .where((p) => p.clave == item.proyecto?.clave)
                  .firstOrNull,
              decoration: const InputDecoration(
                labelText: 'Proyecto',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              // Sin 'style' aquí — deja que el tema maneje el color del valor seleccionado
              dropdownColor: Colors.white, // fondo del menú desplegable
              items: viewModel.proyectos.map((proyecto) {
                return DropdownMenuItem<Proyecto>(
                  value: proyecto,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Text(
                      '${proyecto.clave} - ${proyecto.nombre}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87, // explícito para que siempre sea visible
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (proyecto) {
                viewModel.actualizarProyecto(item, proyecto);
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: item.comentarioVale,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                viewModel.actualizarComentario(item, value);
              },
            ),
          ],
        ),
      ),
    );
  }
}