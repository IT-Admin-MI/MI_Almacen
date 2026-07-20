import 'package:flutter/material.dart';
import 'package:mi_almacen/constants/estado_compra_labels.dart';
import 'package:mi_almacen/models/Compra.dart';

class CompraTimelineCard extends StatelessWidget {
  final Compra compra;
  final bool expandido;
  final bool esUsuarioCompras;
  final bool esSolicitante;
  final bool pendienteAprobacion;
  final bool procesando; // NUEVO
  final VoidCallback onToggle;
  final VoidCallback onAvanzar;
  final VoidCallback onAprobarRevision;

  const CompraTimelineCard({
    super.key,
    required this.compra,
    required this.expandido,
    required this.esUsuarioCompras,
    required this.esSolicitante,
    required this.pendienteAprobacion,
    required this.procesando, // NUEVO
    required this.onToggle,
    required this.onAvanzar,
    required this.onAprobarRevision,
  });

  // build() sin cambios...

  Widget _accion(BuildContext context, {required bool esUltimoEstado}) {
    if (pendienteAprobacion && esSolicitante) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.metint01,
            foregroundColor: Colors.white,
          ),
          onPressed: procesando ? null : onAprobarRevision,
          icon: procesando
              ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.check_circle_outline),
          label: Text(procesando ? 'Aprobando...' : 'Aprobar compra'),
        ),
      );
    }

    if (pendienteAprobacion && esUsuarioCompras) {
      // sin cambios
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
        ),
        child: Row(
          children: const [
            Icon(Icons.hourglass_top, size: 18, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Esperando aprobación del solicitante',
                style: TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    if (esUsuarioCompras) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.metint01,
            foregroundColor: Colors.white,
          ),
          onPressed: (procesando || esUltimoEstado) ? null : onAvanzar,
          icon: procesando
              ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.arrow_forward),
          label: Text(
            procesando
                ? 'Guardando...'
                : (esUltimoEstado ? 'Compra liberada' : 'Pasar al siguiente estado'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final estadoActualIndex = compra.estado.index;
    final esUltimoEstado = estadoActualIndex == EstadoCompra.values.length - 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      compra.nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (!expandido)
                _TimelineCompacto(estadoActualIndex: estadoActualIndex),

              if (expandido) ...[
                const SizedBox(height: 4),
                _TimelineExpandido(estadoActualIndex: estadoActualIndex),
                const SizedBox(height: 12),
                _accion(context, esUltimoEstado: esUltimoEstado),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineCompacto extends StatelessWidget {
  final int estadoActualIndex;

  const _TimelineCompacto({required this.estadoActualIndex});

  @override
  Widget build(BuildContext context) {
    final total = EstadoCompra.values.length;

    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isEven) {
          final estadoIndex = i ~/ 2;
          final completado = estadoIndex <= estadoActualIndex;

          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completado ? Colors.green : Colors.grey.shade400,
            ),
          );
        } else {
          final estadoIndex = i ~/ 2;
          final completado = estadoIndex < estadoActualIndex;

          return Expanded(
            child: Container(
              height: 2,
              color: completado ? Colors.green : Colors.grey.shade400,
            ),
          );
        }
      }),
    );
  }
}

class _TimelineExpandido extends StatelessWidget {
  final int estadoActualIndex;

  const _TimelineExpandido({required this.estadoActualIndex});

  @override
  Widget build(BuildContext context) {
    final estados = EstadoCompra.values;

    return Column(
      children: List.generate(estados.length, (i) {
        final estado = estados[i];
        final completado = i <= estadoActualIndex;
        final esUltimo = i == estados.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completado ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                  if (!esUltimo)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: completado ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  estadoCompraLabels[estado] ?? estado.name,
                  style: TextStyle(
                    fontWeight: i == estadoActualIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: completado ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}