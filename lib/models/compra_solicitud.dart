import 'package:mi_almacen/models/Compra.dart';

enum EstadoSolicitud {
  pendiente,
  aprobada,
  rechazada,
}

class SolicitudCompra {
  final String id;
  final String solicitanteId;
  final DateTime fechaSolicitud;
  final String descripcion;
  final Compra? compra;
  final bool requiereRevisionSolicitante;
  final EstadoSolicitud estado;
  final String? motivoRechazo;
  final String? compradorId;
  final String? compraId;
  final int syncStatus;

  SolicitudCompra({
    required this.id,
    required this.solicitanteId,
    required this.fechaSolicitud,
    required this.descripcion,
    this.compra,
    required this.requiereRevisionSolicitante,
    required this.estado,
    this.motivoRechazo,
    this.compradorId,
    this.compraId,
    required this.syncStatus,
  });

  SolicitudCompra copyWith({
    String? id,
    String? solicitanteId,
    DateTime? fechaSolicitud,
    String? descripcion,
    Compra? compra,
    bool? requiereRevisionSolicitante,
    EstadoSolicitud? estado,
    String? motivoRechazo,
    String? compradorId,
    String? compraId,
    int? syncStatus,
  }) {
    return SolicitudCompra(
      id: id ?? this.id,
      solicitanteId: solicitanteId ?? this.solicitanteId,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      descripcion: descripcion ?? this.descripcion,
      compra: compra ?? this.compra,
      requiereRevisionSolicitante:
      requiereRevisionSolicitante ??
          this.requiereRevisionSolicitante,
      estado: estado ?? this.estado,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      compradorId: compradorId ?? this.compradorId,
      compraId: compraId ?? this.compraId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'solicitante_id': solicitanteId,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'descripcion': descripcion,
      'requiere_revision_solicitante':
      requiereRevisionSolicitante ? 1 : 0,
      'estado': estado.index,
      'motivo_rechazo': motivoRechazo,
      'comprador_id': compradorId,
      'compra_id': compraId,
      'sync_status': syncStatus,
    };
  }

  factory SolicitudCompra.fromMap(
      Map<String, dynamic> map, {
        Compra? compra,
      }) {
    return SolicitudCompra(
      id: map['id'].toString(),
      solicitanteId: map['solicitante_id'],
      fechaSolicitud:
      DateTime.parse(map['fecha_solicitud']),
      descripcion: map['descripcion'],
      compra: compra,
      requiereRevisionSolicitante:
      map['requiere_revision_solicitante'] == true ||
          map['requiere_revision_solicitante'] == 1,
      estado: EstadoSolicitud.values[map['estado']],
      motivoRechazo: map['motivo_rechazo'],
      compradorId: map['comprador_id'],
      compraId: map['compra_id'],
      syncStatus: map['sync_status'] ?? 0,
    );
  }
}