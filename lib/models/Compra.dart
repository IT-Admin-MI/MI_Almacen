import 'package:mi_almacen/models/CompraItem.dart';

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
  agregadoSistema,
}

class Compra {
  final String? id;
  final String nombre;
  final String? descripcion;
  final String ordenCompra;
  final DateTime fechaSolicitud;
  final DateTime? fechaEntrega;
  final EstadoCompra estado;
  final int estatus;
  final List<CompraItem> items;
  final int sync_status;

  Compra({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.ordenCompra,
    required this.fechaSolicitud,
    this.fechaEntrega,
    required this.estado,
    required this.estatus,
    required this.items,
    required this.sync_status,
  });

  Compra copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? ordenCompra,
    DateTime? fechaSolicitud,
    DateTime? fechaEntrega,
    EstadoCompra? estado,
    int? estatus,
    List<CompraItem>? items,
    int? sync_status,
  }) {
    return Compra(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      ordenCompra: ordenCompra ?? this.ordenCompra,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      estatus: estatus ?? this.estatus,
      items: items ?? this.items,
      sync_status: sync_status ?? this.sync_status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'orden_compra': ordenCompra,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'estado': estado.index,
      'estatus': estatus,
      'sync_status': sync_status,
    };
  }

  factory Compra.fromMap(
      Map<String, dynamic> map, {
        List<CompraItem> items = const [],
      }) {
    return Compra(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      ordenCompra: map['orden_compra'],
      fechaSolicitud: DateTime.parse(map['fecha_solicitud']),
      fechaEntrega: map['fecha_entrega'] != null
          ? DateTime.parse(map['fecha_entrega'])
          : null,
      estado: EstadoCompra.values[map['estado']],
      estatus: map['estatus'],
      items: items,
      sync_status: map['sync_status'],
    );
  }
}