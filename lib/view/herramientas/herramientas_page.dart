import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mi_almacen/models/herramienta_prestamo.dart';
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
              content: SingleChildScrollView(
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
                    DropdownButtonFormField<Usuario>(
                      value: usuarioSeleccionado,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Prestado a',
                        border: const OutlineInputBorder(),
                        errorText: errorUsuario,
                      ),
                      items: widget.viewModel.usuarios.map((u) {
                        return DropdownMenuItem<Usuario>(
                          value: u,
                          child: Text(
                            '${u.nombre} (${u.descripcion})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (u) =>
                          setDialogState(() => usuarioSeleccionado = u),
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
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado
              ? 'Devolución registrada'
              : 'Error al registrar la devolución'),
        ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: widget.viewModel.actualizar,
              ),
            ],
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
                            leading: _buildImagen(h),
                            title: Text(h.nombre),
                            subtitle: Text(
                              'Prestado a: ${h.usuarioNombre}\n'
                                  'Entregó: ${h.entregadoPorNombre} · '
                                  '${_formatearFecha(h.fechaPrestamo)}\n'
                                  'Estado: ${EstadoHerramienta.nombre(h.estado)}'
                                  '${h.comentario != null && h.comentario!.isNotEmpty ? '\n${h.comentario}' : ''}',
                            ),
                            isThreeLine: true,
                            trailing: prestada
                                ? ElevatedButton(
                              onPressed: () =>
                                  _confirmarDevolucion(h),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Devolver'),
                            )
                                : const Icon(Icons.check_circle,
                                color: Colors.green),
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