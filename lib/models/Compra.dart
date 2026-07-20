import 'package:mi_almacen/models/CompraItem.dart';

enum TipoCompra {
  proyecto,
  stock,
}

enum EstadoCompra {
  solicitado,
  cotizacion,
  ocSolicitada,
  ocRealizada,
  ocVerificada,
  ocAutorizada,
  ocPagada,
  productoEnviado,
  productoRecibido,
  factura,
  revisionSolicitante,
  agregadoSistema,
  liberada,
}

class Compra {
  final String? id;
  final String nombre;
  final String? comentario;
  final String solicitudId;
  final String ordenCompra;
  final TipoCompra tipoCompra;
  final String compradorId;
  final DateTime fechaSolicitud;
  final DateTime? fechaEntrega;
  final EstadoCompra estado;
  final bool requiereRevisionSolicitante;
  final bool revisionSolicitanteRealizada;
  final DateTime? fechaRevisionSolicitante;
  final String? usuarioRevisionId;
  final bool liberada;
  final DateTime? fechaLiberacion;
  final String? almacenistaId;
  final int estatus;
  final List<CompraItem> items;
  final int syncStatus;

  Compra({
    this.id,
    required this.nombre,
    this.comentario,
    required this.solicitudId,
    required this.ordenCompra,
    required this.tipoCompra,
    required this.compradorId,
    required this.fechaSolicitud,
    this.fechaEntrega,
    required this.estado,
    required this.requiereRevisionSolicitante,
    required this.revisionSolicitanteRealizada,
    this.fechaRevisionSolicitante,
    this.usuarioRevisionId,
    required this.liberada,
    this.fechaLiberacion,
    this.almacenistaId,
    required this.estatus,
    required this.items,
    required this.syncStatus,
  });

  Compra copyWith({
    String? id,
    String? nombre,
    String? comentario,
    String? solicitudId,
    String? ordenCompra,
    TipoCompra? tipoCompra,
    String? compradorId,
    DateTime? fechaSolicitud,
    DateTime? fechaEntrega,
    EstadoCompra? estado,
    bool? requiereRevisionSolicitante,
    bool? revisionSolicitanteRealizada,
    DateTime? fechaRevisionSolicitante,
    String? usuarioRevisionId,
    bool? liberada,
    DateTime? fechaLiberacion,
    String? almacenistaId,
    int? estatus,
    List<CompraItem>? items,
    int? syncStatus,
  }) {
    return Compra(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      comentario: comentario ?? this.comentario,
      solicitudId: solicitudId ?? this.solicitudId,
      ordenCompra: ordenCompra ?? this.ordenCompra,
      tipoCompra: tipoCompra ?? this.tipoCompra,
      compradorId: compradorId ?? this.compradorId,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      requiereRevisionSolicitante:
      requiereRevisionSolicitante ?? this.requiereRevisionSolicitante,
      revisionSolicitanteRealizada:
      revisionSolicitanteRealizada ??
          this.revisionSolicitanteRealizada,
      fechaRevisionSolicitante:
      fechaRevisionSolicitante ??
          this.fechaRevisionSolicitante,
      usuarioRevisionId:
      usuarioRevisionId ?? this.usuarioRevisionId,
      liberada: liberada ?? this.liberada,
      fechaLiberacion:
      fechaLiberacion ?? this.fechaLiberacion,
      almacenistaId:
      almacenistaId ?? this.almacenistaId,
      estatus: estatus ?? this.estatus,
      items: items ?? this.items,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'comentario': comentario,
      'solicitud_id': solicitudId,
      'orden_compra': ordenCompra,
      'tipo_compra': tipoCompra.index,
      'comprador_id': compradorId,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'estado': estado.index,
      'requiere_revision_solicitante':
      requiereRevisionSolicitante ? 1 : 0,
      'revision_solicitante_realizada':
      revisionSolicitanteRealizada ? 1 : 0,
      'fecha_revision_solicitante':
      fechaRevisionSolicitante?.toIso8601String(),
      'usuario_revision_id': usuarioRevisionId,
      'liberada': liberada ? 1 : 0,
      'fecha_liberacion':
      fechaLiberacion?.toIso8601String(),
      'almacenista_id': almacenistaId,
      'estatus': estatus,
      'sync_status': syncStatus,
    };
  }

  factory Compra.fromMap(
      Map<String, dynamic> map, {
        List<CompraItem> items = const [],
      }) {
    return Compra(
      id: map['id']?.toString(),
      nombre: map['nombre'],
      comentario: map['comentario'],
      solicitudId: map['solicitud_id'],
      ordenCompra: map['orden_compra'],
      tipoCompra: TipoCompra.values[map['tipo_compra']],
      compradorId: map['comprador_id'],
      fechaSolicitud:
      DateTime.parse(map['fecha_solicitud']),
      fechaEntrega: map['fecha_entrega'] != null
          ? DateTime.parse(map['fecha_entrega'])
          : null,
      estado: EstadoCompra.values[map['estado']],
      requiereRevisionSolicitante:
      map['requiere_revision_solicitante'] == 1,
      revisionSolicitanteRealizada:
      map['revision_solicitante_realizada'] == 1,
      fechaRevisionSolicitante:
      map['fecha_revision_solicitante'] != null
          ? DateTime.parse(
          map['fecha_revision_solicitante'])
          : null,
      usuarioRevisionId:
      map['usuario_revision_id'],
      liberada: map['liberada'] == 1,
      fechaLiberacion:
      map['fecha_liberacion'] != null
          ? DateTime.parse(map['fecha_liberacion'])
          : null,
      almacenistaId:
      map['almacenista_id'],
      estatus: map['estatus'],
      items: items,
      syncStatus: map['sync_status'],
    );
  }
}