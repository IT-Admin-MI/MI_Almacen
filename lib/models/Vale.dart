import 'package:mi_almacen/models/Vale_Item.dart';

class Vale {

  final String id;

  final DateTime fechaCreacion;

  final String usuarioNombre;

  final int usuarioRol;

  final int estado;

  final DateTime? fechaValidacion;

  final String? validadoPor;

  final String? comentarioValidacion;

  final int syncStatus;

  final String? departamento;

  final List<ValeItem> items;

  Vale({
    required this.id,
    required this.fechaCreacion,
    required this.usuarioNombre,
    required this.usuarioRol,
    required this.estado,
    required this.items,
    required this.departamento,
    this.fechaValidacion,
    this.validadoPor,
    this.comentarioValidacion,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {

    return {

      'id': id,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'usuario_nombre': usuarioNombre,
      'usuario_rol': usuarioRol,
      'estado': estado,
      'departamento': departamento,
      'fecha_validacion': fechaValidacion?.toIso8601String(),
      'validado_por': validadoPor,
      'comentario_validacion': comentarioValidacion,
      'sync_status': syncStatus,
    };
  }

  factory Vale.fromMap(
      Map<String, dynamic> map,
      List<ValeItem> items,
      ) {

    return Vale(

      id:
      map['id'] as String,

      fechaCreacion:
      DateTime.parse(
        map['fecha_creacion'] as String,
      ),

      usuarioNombre:
      map['usuario_nombre'] as String,

      departamento:
      map['departamento'] as String,

      usuarioRol:
      map['usuario_rol'] as int,

      estado:
      map['estado'] as int,

      items:
      items,

      fechaValidacion:
      map['fecha_validacion'] != null
          ? DateTime.parse(
        map['fecha_validacion']
        as String,
      )
          : null,

      validadoPor:
      map['validado_por']
      as String?,

      comentarioValidacion:
      map['comentario_validacion']
      as String?,

      syncStatus:
      map['sync_status']
      as int? ??
          0,
    );
  }
}