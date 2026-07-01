import 'dart:ffi';

class Proyecto {
  final String clave;
  final String nombre;
  final DateTime? fechaEntrega;
  final int orden;
  final bool status;

  Proyecto({
    required this.clave,
    required this.nombre,
    this.fechaEntrega,
    required this.orden,
    required this.status,
  });

  Map<String, dynamic> toMap() {

    return {
      'clave': clave,
      'nombre': nombre,
      'orden': orden,
      'status': status ? 1 : 0,
      'fechaEntrega':
      fechaEntrega
          ?.toIso8601String(),
    };
  }

  factory Proyecto.fromMap(
      Map<String, dynamic> map,
      ) {

    return Proyecto(
      clave: map['clave'],
      nombre: map['nombre'],
      orden: map['orden'] as int? ?? 0,
      status: (map['status'] ?? 1) == 1,
      fechaEntrega:
      map['fechaEntrega'] != null
          ? DateTime.parse(
        map['fechaEntrega'],
      )
          : null,
    );
  }

  factory Proyecto.fromFirebase(
      Map<String, dynamic> data,
      ) {
    bool _parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }
    return Proyecto(
      clave: data['codigo'] ?? '',
      nombre: data['nombre'] ?? '',
      status: _parseBool(data['status']),
      fechaEntrega: DateTime.parse(
        data['fechaEntrega'],
      ),
      orden: data['orden'] ?? 0,
    );

  }

}