class Proyecto {
  final String clave;
  final String descripcion;
  final DateTime fecha_entrega;

  Proyecto({
    required this.clave,
    required this.descripcion,
    required this.fecha_entrega,
  });

  Map<String, dynamic> toMap() {
    return {
      'clave': clave,
      'descripcion': descripcion,
      'fecha_entrega':fecha_entrega,
    };
  }

  factory Proyecto.fromMap(Map<String, dynamic> map) {
    return Proyecto(
      clave: map['clave'],
      descripcion: map['descripcion'],
      fecha_entrega: map['fecha_entrega'],
    );
  }
}