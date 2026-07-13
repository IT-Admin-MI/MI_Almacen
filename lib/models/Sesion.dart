class SesionUsuario {

  final String? usuarioId;

  final String nombre;

  final int rol;

  final departamento;

  SesionUsuario({
    this.usuarioId,
    required this.nombre,
    required this.rol,
    required this.departamento,
  });

  Map<String, dynamic> toMap() {

    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'departamento': departamento,
      'rol': rol,
    };
  }

  factory SesionUsuario.fromMap(
      Map<String, dynamic> map,
      ) {

    return SesionUsuario(
      usuarioId: map['usuarioId'],
      nombre: map['nombre'],
      departamento: map['departamento'],
      rol: int.parse(
        map['rol'].toString(),
      ),
    );
  }
}