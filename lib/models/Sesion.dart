class SesionUsuario {

  final int? usuarioId;

  final String nombre;

  final int rol;

  SesionUsuario({
    this.usuarioId,
    required this.nombre,
    required this.rol,
  });

  Map<String, dynamic> toMap() {

    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'rol': rol,
    };
  }

  factory SesionUsuario.fromMap(
      Map<String, dynamic> map,
      ) {

    return SesionUsuario(
      usuarioId: map['usuarioId'],
      nombre: map['nombre'],
      rol: int.parse(
        map['rol'].toString(),
      ),
    );
  }
}