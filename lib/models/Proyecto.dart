import 'dart:ffi';

class Proyecto {
  final String clave;
  final String nombre;
  final DateTime? fechaEntrega;
  final int orden;

  Proyecto({
    required this.clave,
    required this.nombre,
    this.fechaEntrega,
    required this.orden,
  });

  Map<String, dynamic> toMap() {

    return {
      'clave': clave,
      'nombre': nombre,
      'orden': orden,

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
      orden: map['orden'] ?? 0,

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

    return Proyecto(
      clave: data['codigo'] ?? '',
      nombre: data['nombre'] ?? '',
      fechaEntrega: DateTime.parse(
        data['fechaEntrega'],
      ),
      orden: data['orden'] ?? '',
    );
  }
}