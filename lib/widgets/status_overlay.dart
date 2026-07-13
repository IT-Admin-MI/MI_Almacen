import 'dart:async';
import 'package:flutter/material.dart';

enum _EstadoTipo { cargando, exito, error }

class _EstadoOverlay {
  final _EstadoTipo tipo;
  final String mensaje;
  const _EstadoOverlay(this.tipo, this.mensaje);
}

class StatusOverlayController {
  final OverlayEntry _entry;
  final ValueNotifier<_EstadoOverlay> _notifier;
  Timer? _autoCloseTimer;

  StatusOverlayController._(this._entry, this._notifier);

  /// Cambia la ventana de "Enviando..." al resultado final (éxito o error).
  /// Se cierra sola después de [duracion].
  void completar({
    required bool exito,
    required String mensaje,
    Duration duracion = const Duration(seconds: 2),
  }) {
    _notifier.value = _EstadoOverlay(
      exito ? _EstadoTipo.exito : _EstadoTipo.error,
      mensaje,
    );

    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(duracion, cerrar);
  }

  /// Cierra manualmente el overlay (por si necesitas cancelarlo antes).
  void cerrar() {
    _autoCloseTimer?.cancel();
    if (_entry.mounted) {
      _entry.remove();
    }
  }
}

class StatusOverlay {
  /// Muestra la ventana con una ruleta de carga y el mensaje indicado.
  /// Devuelve un controlador para luego llamar a `.completar(...)`.
  static StatusOverlayController mostrarCargando(
      BuildContext context, {
        String mensaje = 'Enviando...',
      }) {
    final overlay = Overlay.of(context);
    final notifier = ValueNotifier<_EstadoOverlay>(
      _EstadoOverlay(_EstadoTipo.cargando, mensaje),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _StatusOverlayContent(notifier: notifier),
    );

    overlay.insert(entry);

    return StatusOverlayController._(entry, notifier);
  }

  /// Atajo para cuando ya tienes el resultado y no necesitas mostrar "cargando" antes.
  static void mostrar(
      BuildContext context, {
        required bool exito,
        required String mensaje,
        Duration duracion = const Duration(seconds: 2),
      }) {
    final controller = mostrarCargando(context, mensaje: mensaje);
    controller.completar(exito: exito, mensaje: mensaje, duracion: duracion);
  }
}

class _StatusOverlayContent extends StatefulWidget {
  final ValueNotifier<_EstadoOverlay> notifier;

  const _StatusOverlayContent({required this.notifier});

  @override
  State<_StatusOverlayContent> createState() => _StatusOverlayContentState();
}

class _StatusOverlayContentState extends State<_StatusOverlayContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrada;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _entrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = CurvedAnimation(parent: _entrada, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _entrada,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _entrada.forward();

    widget.notifier.addListener(_onEstadoCambia);
  }

  void _onEstadoCambia() {
    // Solo hace falta refrescar el AnimatedSwitcher interno, no repetir la
    // animación de entrada de la tarjeta.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onEstadoCambia);
    _entrada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.notifier.value;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.15),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.elasticOut,
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _buildIcono(estado),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        estado.mensaje,
                        key: ValueKey(estado.mensaje),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcono(_EstadoOverlay estado) {
    switch (estado.tipo) {
      case _EstadoTipo.cargando:
        return const SizedBox(
          key: ValueKey('cargando'),
          width: 64,
          height: 64,
          child: CircularProgressIndicator(strokeWidth: 4),
        );
      case _EstadoTipo.exito:
        return const Icon(
          Icons.check_circle,
          key: ValueKey('exito'),
          color: Colors.green,
          size: 64,
        );
      case _EstadoTipo.error:
        return const Icon(
          Icons.cancel,
          key: ValueKey('error'),
          color: Colors.red,
          size: 64,
        );
    }
  }
}