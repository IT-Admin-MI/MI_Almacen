import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mi_almacen/models/herramienta_prestamo.dart';
import 'package:mi_almacen/widgets/status_overlay.dart';
import '../../models/Usuario.dart';
import '../../viewmodels/herramientas_viewmodel.dart';

class HerramientasPage extends StatefulWidget {
  final HerramientasViewModel viewModel;

  const HerramientasPage({super.key, required this.viewModel});

  @override
  State<HerramientasPage> createState() => _HerramientasPageState();
}

class _HerramientasPageState extends State<HerramientasPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.inicializar();
  }

  Future<void> _mostrarDialogoNuevoPrestamo() async {
    final nombreCtrl = TextEditingController();
    final comentarioCtrl = TextEditingController();
    final codigoController = TextEditingController();
    Usuario? usuarioSeleccionado;
    String? imagenPath;
    String? errorNombre;
    String? errorUsuario;

    await showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo préstamo'),

              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(
                          labelText: 'Herramienta',
                          border: const OutlineInputBorder(),
                          errorText: errorNombre,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codigoController,
                        decoration: const InputDecoration(
                          labelText: "Código",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) async {
                          await widget.viewModel.buscarMaterial(value);
                          setDialogState(() {});
                        },
                      ),

                      if(widget.viewModel.resultadosBusquedaMaterial.isNotEmpty)

                        Container(
                          height: 180,

                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: ListView.builder(
                            itemCount:
                            widget.viewModel.resultadosBusquedaMaterial.length,
                            itemBuilder: (_,index){
                              final material =
                              widget.viewModel.resultadosBusquedaMaterial[index];
                              return ListTile(
                                dense: true,
                                title: Text(material.descripcion),
                                subtitle: Text(material.codigo),
                                trailing: Text(material.existencia.toString()),
                                onTap: () {

                                  codigoController.text = material.codigo;
                                  nombreCtrl.text = material.descripcion;

                                  widget.viewModel.limpiarBusquedaMaterial();

                                  setDialogState(() {});

                                },
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<Usuario>(
                        value: usuarioSeleccionado,
                        isExpanded: true,

                        decoration: const InputDecoration(
                          labelText: 'Prestar a',
                          border: OutlineInputBorder(),
                        ),

                        items: widget.viewModel.usuarios.map((u) {
                          return DropdownMenuItem<Usuario>(
                            value: u,
                            child: Text(
                              '${u.nombre} (${u.descripcion})',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),

                        onChanged: (usuario) {
                          setDialogState(() {
                            usuarioSeleccionado = usuario;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: comentarioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Comentario (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // SELECTOR DE IMAGEN
                      if (imagenPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagenPath!),
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (!kIsWeb && Platform.isAndroid)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            imagenPath == null
                                ? 'Tomar fotografía'
                                : 'Cambiar fotografía',
                          ),
                          onPressed: () async {
                            final path = await widget.viewModel.tomarFotografia();
                            if (path != null) {
                              setDialogState(() => imagenPath = path);
                            }
                          },
                        ),
                    ],
                  ),
                ),),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool valido = true;

                    if (nombreCtrl.text.trim().isEmpty) {
                      setDialogState(() =>
                      errorNombre = 'Ingresa el nombre de la herramienta');
                      valido = false;
                    } else {
                      setDialogState(() => errorNombre = null);
                    }

                    if (usuarioSeleccionado == null) {
                      setDialogState(
                              () => errorUsuario = 'Selecciona un usuario');
                      valido = false;
                    } else {
                      setDialogState(() => errorUsuario = null);
                    }

                    if (!valido) return;

                    final ok = await widget.viewModel.registrarPrestamo(
                      nombre: nombreCtrl.text.trim(),
                      comentario: comentarioCtrl.text.trim().isEmpty
                          ? null
                          : comentarioCtrl.text.trim(),
                      imagenPath: imagenPath,
                      usuarioDestino: usuarioSeleccionado!,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Préstamo registrado'
                              : 'Error al registrar el préstamo'),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarDevolucion(HerramientaPrestamo h) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar devolución'),
        content: Text('¿Confirmar devolución de "${h.nombre}" '
            'prestada a ${h.usuarioNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Devolver'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final resultado = await widget.viewModel.registrarDevolucion(h.id);
      if (!mounted) return;
      StatusOverlay.mostrar(
        context,
        exito: resultado,
        mensaje: resultado
            ? 'Devolución registrada'
            : 'Error al registrar la devolución',
        duracion: const Duration(seconds: 2),
      );
    }
  }

  String _formatearFecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
          '${f.month.toString().padLeft(2, '0')}/${f.year}';

  Widget _buildImagen(HerramientaPrestamo h) {
    if (h.imagenPath != null && File(h.imagenPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(h.imagenPath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }

    if (h.imagenUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          h.imagenUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.build, size: 40, color: Colors.grey),
        ),
      );
    }

    return const Icon(Icons.build, size: 40, color: Colors.grey);
  }

  Future<void> _mostrarDialogoReutilizar(
      HerramientaPrestamo herramienta) async {

    Usuario? usuarioSeleccionado;

    await showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              titlePadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),

              // 2. Envuelve el texto en un Center o usa un Align
              title: const Center(
                child: Text("Prestar herramienta"),
              ),

              content: SizedBox(
                width: 350,

                child: SingleChildScrollView(

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade200,
                        child: _buildImagen(herramienta),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        herramienta.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Último préstamo a\n${herramienta.usuarioNombre}",
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Nuevo usuario",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownMenu<Usuario>(
                        width: 320,

                        initialSelection: usuarioSeleccionado,

                        hintText: "Selecciona un usuario",

                        onSelected: (u) {
                          setState(() {
                            usuarioSeleccionado = u;
                          });
                        },

                        dropdownMenuEntries:

                        widget.viewModel.usuarios.map((u) {

                          return DropdownMenuEntry<Usuario>(

                            value: u,

                            label: u.nombre,

                            leadingIcon: const Icon(Icons.person),

                          );

                        }).toList(),

                      ),

                    ],

                  ),

                ),

              ),

              actions: [

                TextButton(

                  onPressed: () => Navigator.pop(context),

                  child: const Text("Cancelar"),

                ),

                FilledButton(

                  onPressed: usuarioSeleccionado == null
                      ? null
                      : () async {

                    final ok =
                    await widget.viewModel.reutilizarPrestamo(
                      herramienta: herramienta,
                      usuarioDestino: usuarioSeleccionado!,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    StatusOverlay.mostrar(
                      context,
                      exito: ok,
                      mensaje: ok
                          ? 'Préstamo registrado'
                          : 'Error al registrar el préstamo',
                      duracion: const Duration(seconds: 2),
                    );

                  },

                  child: const Text("Prestar"),

                ),

              ],

            );

          },

        );

      },

    );

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final herramientas = widget.viewModel.herramientas;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo_ext.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: widget.viewModel.actualizar,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Herramientas prestadas',
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SwitchListTile(
                    title: const Text('Mostrar solo prestadas'),
                    value: widget.viewModel.soloPrestadas,
                    onChanged: widget.viewModel.cambiarFiltro,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String?>(
                      value: widget.viewModel.departamentoSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por departamento',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos los departamentos'),
                        ),
                        ...widget.viewModel.departamentos.map(
                              (d) => DropdownMenuItem<String?>(
                            value: d,
                            child: Text(d),
                          ),
                        ),
                      ],
                      onChanged: widget.viewModel.cambiarDepartamento,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: widget.viewModel.cargando
                        ? const Center(child: CircularProgressIndicator())
                        : herramientas.isEmpty
                        ? const Center(child: Text('No hay registros'))
                        : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: herramientas.length,
                      itemBuilder: (context, index) {
                        final h = herramientas[index];
                        final prestada =
                            h.estado == EstadoHerramienta.prestado;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                              onLongPress: () {
                                if (h.estado == EstadoHerramienta.devuelto) {
                                  _mostrarDialogoReutilizar(h);
                                }
                              },

                              leading: _buildImagen(h),

                              title: Text(h.nombre),

                              subtitle: Text(
                                'Prestado a: ${h.usuarioNombre}\n'
                                    '${_formatearFecha(h.fechaPrestamo)}\n'
                                    'Estado: ${EstadoHerramienta.nombre(h.estado)}'
                                    '${h.comentario != null && h.comentario!.isNotEmpty ? '\n${h.comentario}' : ''}',
                              ),

                              isThreeLine: true,

                              trailing: prestada
                                  ? SizedBox(
                                height: 150,
                                width: 45,
                                child: ElevatedButton(
                                  onPressed: () => _confirmarDevolucion(h),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_return,
                                    size: 30,
                                  ),
                                ),
                              )
                                  : Container(
                                width: 45, // Ancho horizontal extendido
                                height: 150, // Alto del contenedor
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2), // Fondo del rectángulo
                                  borderRadius: BorderRadius.circular(8), // Bordes redondeados
                                ),
                                child: const Icon(
                                  Icons.check_box_rounded,
                                  size: 35, // Ajustado para caber dentro del contenedor
                                  color: Colors.grey,
                                ),
                              )

                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _mostrarDialogoNuevoPrestamo,
            backgroundColor: const Color(0xFF4B4E6C),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}