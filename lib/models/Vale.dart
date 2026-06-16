class Vale {
  final int? id;
  final String proyectoClave;
  final DateTime fecha;
  final String usuario;
  final String estatus;
  final String observaciones;

  Vale({
    this.id,
    required this.proyectoClave,
    required this.fecha,
    required this.usuario,
    required this.estatus,
    required this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proyecto_clave': proyectoClave,
      'fecha': fecha.toIso8601String(),
      'usuario': usuario,
      'estatus': estatus,
      'observaciones': observaciones,
    };
  }

  factory Vale.fromMap(Map<String, dynamic> map) {
    return Vale(
      id: map['id'],
      proyectoClave: map['proyecto_clave'],
      fecha: DateTime.parse(map['fecha']),
      usuario: map['usuario'],
      estatus: map['estatus'],
      observaciones: map['observaciones'],
    );
  }
}